//+------------------------------------------------------------------+
//|                                           WillsNeuralNetwork.mqh |
//|                                                 William Nicholas |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "William Nicholas"
#property link      "https://www.mql5.com"
#include <Math\Stat\Normal.mqh>


class WillsNeuralNetwork{

      protected:
         
         
         int m_deep;
         int m_depth;
         string m_Symbol;
         double close[];   
         matrix m_input;
         matrix m_pred_input;
         ENUM_TIMEFRAMES m_TF;
         matrix m_z_2;
         matrix m_a_2; 
         matrix m_z_3;
         matrix m_yHat;
         double y_cor;
         double m_alpha;
      public:
      matrix W_1;
      matrix W_2;
      matrix W_1_LSTM;
      WillsNeuralNetwork(string Symbol_ , ENUM_TIMEFRAMES TimeFrame , int History_Depth, int Number_of_Neurons,double alpha );
      double Sigmoid(double x);
      double Sigmoid_Prime(double x);
      int    Sgn(double Value);      
      void   MatrixRandom(matrix& m);
      matrix MatrixSigmoidPrime(matrix& m);
      matrix MatrixSigmoid(matrix& m);
      void   UpdateValues(int shift);
      matrix Forward_Prop();
      double Cost();
      void   Train(int shift ); 
      double Prediction();





};

WillsNeuralNetwork::WillsNeuralNetwork(string Symbol_ , ENUM_TIMEFRAMES TimeFrame , int History_Depth, int Number_of_Neurons,double alpha  ) {
       
       m_Symbol= Symbol_;
       m_depth = History_Depth;
       m_deep  = Number_of_Neurons;
       m_TF = TimeFrame;
       m_alpha = alpha;
       matrix random_LSTM(1, m_deep);
       matrix random_W1(m_depth, m_deep);
       matrix random_W2(m_deep, 1);
       
       MatrixRandom(random_W1);
       MatrixRandom(random_W2);
       MatrixRandom(random_LSTM);
       
       
       W_1      =   random_W1;
       W_2      = random_W2; 
       W_1_LSTM = random_LSTM;
      
      
       ArrayResize(close,m_depth+5,0);
      
       m_yHat.Init(1,1);
       m_yHat[0][0]=0;
       y_cor = -1;
       
       
       
       
       
       }


double WillsNeuralNetwork::Prediction(void){

       
   matrix pred_z_2 = m_pred_input.MatMul(W_1) + W_1_LSTM ;
   
   
   matrix pred_a_2 = MatrixSigmoid(pred_z_2);
   
   matrix pred_z_3 = pred_a_2.MatMul(W_2);
   
   matrix pred_yHat = MatrixSigmoid(pred_z_3);
   
   //Print("yHat = ",yHat);
   
   return pred_yHat[0][0];


}

void WillsNeuralNetwork::Train(int shift){

      bool Train_condition = true;
      UpdateValues(shift);
      
      while( Train_condition){
   
    
           m_yHat= Forward_Prop();
   
   double J = Cost();
   //Print(J);
   /// alpha =.00000001
   if( J <m_alpha){
    Train_condition = false;
   }
   
   ///Print(J);
         
        matrix X_m_matrix = {{y_cor}}; 
  
        matrix cost =-1*(X_m_matrix-m_yHat);
        //Print(cost);
        matrix z_3_prime = MatrixSigmoidPrime(m_z_3);
        
        matrix delta3 = cost.MatMul(z_3_prime);
       
        matrix dJdW2 = m_a_2.Transpose().MatMul(delta3); 
        
        
        
        
        matrix z_2_prime = MatrixSigmoidPrime(m_z_2);
        matrix delta2 = delta3.MatMul(W_2.Transpose())*z_2_prime;
        
        
        matrix dJdW1 = m_input.Transpose().MatMul( delta2);
        
        W_1 = W_1 -dJdW1; 
        W_2 = W_2 -dJdW2;
         
   }
   //Print( MathExp(-5));
   //Print(SGD(.6));
   
    W_1_LSTM = MatrixSigmoid(m_input.MatMul(W_1));
   





}
       
double WillsNeuralNetwork::Cost(void){


      double J = .5*pow( y_cor -m_yHat[0][0] ,2 );
      return J; 
}       
       
       
matrix WillsNeuralNetwork::Forward_Prop(void){



    
   m_z_2 = m_input.MatMul(W_1) + W_1_LSTM ;
   
   
   m_a_2 = MatrixSigmoid(m_z_2);
   
   m_z_3 = m_a_2.MatMul(W_2);
   
   m_yHat = MatrixSigmoid(m_z_3);
   
   //Print("yHat = ",yHat);
   
   return m_yHat;



}

void WillsNeuralNetwork::UpdateValues(int shift){

         
    
   for( int i =0 ; i< m_depth+5 ; i++){
   
      close[i] = iClose(m_Symbol,m_TF,i+shift);
      
   
   }
 
   m_input.Init(1,m_depth);
   
   for(int i=0+1; i<m_depth+1; i++){
      m_input[0][i-1]= close[i];
      }
       
       
   m_pred_input.Init(1,m_depth);
   
   for(int i=0; i<m_depth; i++){
      m_input[0][i]= close[i];
      }    
       
    y_cor = (Sgn(close[0]-close[1])+1)/2;
       


}


double WillsNeuralNetwork::Sigmoid(double x) {
       return(1/(1+MathExp(-x) )); 
       
       }

double WillsNeuralNetwork::Sigmoid_Prime(double x){ 
       
       return( MathExp(-x)/(pow(1+MathExp(-x),2) ));
       
       }
       
int WillsNeuralNetwork::Sgn(double Value){

   int res;

   if (Value>0 ){
      res = 1;
     
   }
   else{
      res = -1;
   }
   return res;
}


void WillsNeuralNetwork::MatrixRandom(matrix& m)
 {
   int error;
  for(ulong r=0; r<m.Rows(); r++)
   {
    for(ulong c=0; c<m.Cols(); c++)
     {
      
      m[r][c]= MathRandomNormal(0,1,error);
     }
   }
 }
 
 
 
 
matrix WillsNeuralNetwork::MatrixSigmoid(matrix& m)
 {
  matrix m_2;
  m_2.Init(m.Rows(),m.Cols());
  for(ulong r=0; r<m.Rows(); r++)
   {
    for(ulong c=0; c<m.Cols(); c++)
     {
      m_2[r][c]=Sigmoid(m[r][c]);
     }
   }
   return m_2;
 }



matrix WillsNeuralNetwork::MatrixSigmoidPrime(matrix& m)
{
  matrix m_2;
  m_2.Init(m.Rows(),m.Cols());
  for(ulong r=0; r<m.Rows(); r++)
   {
    for(ulong c=0; c<m.Cols(); c++)
     {
      m_2[r][c]= Sigmoid_Prime(m[r][c]);
     }
   }
   return m_2;
 }


