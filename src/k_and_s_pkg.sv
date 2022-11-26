package k_and_s_pkg;
  typedef enum  logic [4:0] {
     I_NOP          = "000000"   
,    I_LOAD        = "000001"    
,    I_STORE       = "000010"      
,    I_MOVE        = "000011"    
,    I_ADD         = "000100"    
,    I_SUB         = "000101"    
,    I_AND         = "000110"    
,    I_OR          = "000111"  
,    I_BRANCH      = "001000"      
,    I_BZERO       = "001001" 
,    I_BNZERO      = "001010" 
,    I_BNEG        = "001011" 
,    I_BNNEG       = "001100" 
,    I_BOV         = "001101" 
,    I_BNOV        = "001110" 
,    I_HALT        = "11111" 
} decoded_instruction_type;  // Decoded instruction in decode

endpackage : k_and_s_pkg
