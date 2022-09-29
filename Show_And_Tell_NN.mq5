//+------------------------------------------------------------------+
//|                                                         Ai_3.mq5 |
//|                                                 William Nicholas |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+


input double Lot                      = 1.05;
double  pip                           = _Point*10;
input int TPinPips                    = 5;
input int SLinPips                    = 5;
input int MagicNumberBUY              = 66691; 
input int MagicNumberSELL             = 66692;
input ENUM_TIMEFRAMES TimeFrame       = PERIOD_H1;
input int min                         = 50;
input int number_of_neurons           = 15;
input int history_depth               = 15;
#include <WillsNeuralNetwork.mqh>
#include<Trade\Trade.mqh>
#include <Trade\AccountInfo.mqh>
#include <Trade\PositionInfo.mqh>



CAccountInfo AccInfo;
CTrade trading;  
CPositionInfo m_position; 



WNN WNN_2(_Symbol,TimeFrame,history_depth,number_of_neurons,.00000001);







int OnInit()
  {
//---
        
   
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+


void OnTick()
  {
//---
   
   datetime    tm=TimeCurrent();
   MqlDateTime stm;
   TimeToStruct(tm,stm);
   
   int TimeCheck = 0; 
   
   if (  stm.day_of_week==2 || stm.day_of_week==3 || stm.day_of_week==4 && stm.hour>7 && stm.hour<15  ){
      TimeCheck = 1;
   
   }
   
   
      if(m_position.SelectByMagic(_Symbol,MagicNumberBUY)){
   
      if( (long)m_position.Time() + 60*min < (long)TimeCurrent()){
      
         trading.PositionClose(m_position.Ticket(),-1);
      
      }
   
   }
   
   
   if(m_position.SelectByMagic(_Symbol,MagicNumberSELL)){
   
   
      if( (long)m_position.Time() + 60*min < (long)TimeCurrent()){
      
         trading.PositionClose(m_position.Ticket(),-1);
      
      }
   
   }
   
   
  
     bool TradeTracker = (m_position.SelectByMagic(_Symbol,MagicNumberBUY) == false) &&(m_position.SelectByMagic(_Symbol,MagicNumberSELL) == false);
     
   if(stm.min==1){
   
        WNN_2.Train(0);
       
        double Pred = WNN_2.Prediction(); 
        Print(Pred);
        
   if(Pred <.5 && TradeTracker && TimeCheck==1   ){
   
   //buy 
   
   
     double TakeProfit = pip*TPinPips;
   double StopLoss = pip*SLinPips;
 
  MqlTradeRequest myrequest;
  MqlTradeResult myresult;
  ZeroMemory(myrequest);
  ZeroMemory(myresult);
  
    
  myrequest.type = ORDER_TYPE_BUY;
  myrequest.action = TRADE_ACTION_DEAL;
  myrequest.sl = SymbolInfoDouble(_Symbol,SYMBOL_BID) - StopLoss;
  myrequest.tp =  SymbolInfoDouble(_Symbol,SYMBOL_ASK)+TakeProfit;//  .00250;
  //myrequest.deviation =20;
  myrequest.symbol = _Symbol;
  myrequest.volume = Lot;
  myrequest.type_filling = ORDER_FILLING_FOK;
  myrequest.price = SymbolInfoDouble(_Symbol,SYMBOL_ASK);
  myrequest.magic = MagicNumberBUY;
  OrderSend(myrequest,myresult);
   }


   if(Pred >.5&& TradeTracker && TimeCheck==1  ){
   
   //sell
   
 
  
  double TakeProfit = pip*TPinPips;
  double StopLoss = pip*SLinPips;
  MqlTradeRequest myrequest;
  MqlTradeResult myresult;
  ZeroMemory(myrequest);
  ZeroMemory(myresult);
  
    
  myrequest.type = ORDER_TYPE_SELL;
  myrequest.action = TRADE_ACTION_DEAL;
  myrequest.sl = SymbolInfoDouble(_Symbol,SYMBOL_ASK) + StopLoss;
  myrequest.tp = SymbolInfoDouble(_Symbol,SYMBOL_BID)- TakeProfit; //  .00250;
  //myrequest.deviation =20;
  myrequest.symbol = _Symbol;
  myrequest.volume = Lot;
  myrequest.type_filling = ORDER_FILLING_FOK;
  myrequest.price = SymbolInfoDouble(_Symbol,SYMBOL_BID);
  myrequest.magic = MagicNumberSELL;
  OrderSend(myrequest,myresult);
   
   
   }
      
   
   
   }
   
   
  }
//+------------------------------------------------------------------+
