package k_and_s_pkg;
  typedef enum  logic [4:0] {
     I_NOP          = "00000"   
,    I_LOAD        =  "00001"    
,    I_STORE       =  "00010"      
,    I_MOVE        =  "00011"    
,    I_ADD         =  "00100"    
,    I_SUB         =  "00101"    
,    I_AND         =  "00110"    
,    I_OR          =  "00111"  
,    I_BRANCH      =  "01000"      
,    I_BZERO       =  "01001" 
,    I_BNZERO      =  "01010" 
,    I_BNEG        =  "01011" 
,    I_BNNEG       =  "01100" 
,    I_BOV         =  "01101" 
,    I_BNOV        =  "01110" 
,    I_HALT        =  "11111" 
} decoded_instruction_type;  // Decoded instruction in decode

endpackage : k_and_s_pkg
