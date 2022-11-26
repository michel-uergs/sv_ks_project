//control unit
module control_unit
import k_and_s_pkg::*;
(
    input  logic                    rst_n,
    input  logic                    clk,
    output logic                    branch,
    output logic                    pc_enable,
    output logic                    ir_enable,
    output logic                    write_reg_enable,
    output logic                    addr_sel,
    output logic                    c_sel,
    output logic              [1:0] operation,
    output logic                    flags_reg_enable,
    input  decoded_instruction_type decoded_instruction,
    input  logic                    zero_op,
    input  logic                    neg_op,
    input  logic                    unsigned_overflow,
    input  logic                    signed_overflow,
    output logic                    ram_write_enable,
    output logic                    halt
);

typedef enum { 
   
    DECODIFICA
,   BUSCA_INSTR
,   REG_INSTR
,   LOAD_1
,   LOAD_2
,   ESCREVE_REG
,   FIM_PROGRAMA

} STATE_T;

STATE_T state;
STATE_T next_state;

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        state <= BUSCA_INSTR; 
    end
    else
        state <= next_state;
end

always_comb begin : calc_next_state
    //VALORES DEFAULT
    branch = 1'd0;
    pc_enable = 1'd0;
    ir_enable = 1'd0;
    write_reg_enable = 1'd0;
    addr_sel = 1'd0;
    c_sel = 1'd0;
    operation = 2'd00;
    flags_reg_enable = 1'd0;
    ram_write_enable = 1'd0;
    halt = 1'd0;

    case (state)
        BUSCA_INSTR: begin    
            next_state = REG_INSTR;
           
        end
        REG_INSTR : begin
            next_state = DECODIFICA;
             ir_enable = 1'b1;
             pc_enable = 1'b1;
        end
    
        DECODIFICA: begin    
            next_state = BUSCA_INSTR;
            if(decoded_instruction == I_HALT)
                next_state = FIM_PROGRAMA;
            else if(decoded_instruction == I_LOAD) begin
                next_state = LOAD_1;
                addr_sel = 1'b1;
            end
        end
        LOAD_1 : begin
            next_state = LOAD_2;
            addr_sel = 1'b1;
            c_sel = 1'b1;
        end
        LOAD_2 : begin 
            next_state = BUSCA_INSTR;
            addr_sel = 1'b1;
            c_sel = 1'b1;
            write_reg_enable = 1'b1;
        end
        FIM_PROGRAMA : begin
            next_state = FIM_PROGRAMA;
            halt = 1'b1;
        end
    endcase
end : calc_next_state

endmodule : control_unit
