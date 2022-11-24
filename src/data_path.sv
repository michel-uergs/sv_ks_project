module data_path
import k_and_s_pkg::*;
(
    input  logic                    rst_n,
    input  logic                    clk,
    input  logic                    branch,
    input  logic                    pc_enable,
    input  logic                    ir_enable,
    input  logic                    addr_sel,
    input  logic                    c_sel,
    input  logic              [1:0] operation,
    input  logic                    write_reg_enable,
    input  logic                    flags_reg_enable,
    output decoded_instruction_type decoded_instruction,
    output logic                    zero_op,
    output logic                    neg_op,
    output logic                    unsigned_overflow,
    output logic                    signed_overflow,
    output logic              [4:0] ram_addr,
    output logic             [15:0] data_out,
    input  logic             [15:0] data_in

);

logic [4:0]     program_counter;
logic [4:0]     mem_addr;
logic [1:0]     a_addr;
logic [1:0]     b_addr;
logic [1:0]     c_addr;
logic [15:0]    bus_a;
logic [15:0]    bus_b;
logic [15:0]    bus_c;
logic [15:0]    ula_out;
logic [15:0]    instruction; 
logic zero;
logic neg;
logic un_ovf;
logic sig_ovf;
logic carry_in_ultimo_bit;

always_ff @(posedge clk ) begin : ir_ctrl
    if (ir_enable) begin
        instruction <= data_in;        
    end
end : ir_ctrl

always_ff @(posedge clk ) begin : pc_ctrl
    if (pc_enable) begin
        if (branch) 
            program_counter <= mem_addr;
        else
            program_counter <= program_counter + 1;
    end
end : pc_ctrl

always_comb begin : ula_ctrl
    case (operation)

        2'b00: begin // soma 
            {carry_in_ultimo_bit, ula_out[14:0]} = bus_a[14:0] + bus_b[14:0]
            {un_ovf, ula_out[15]} = bus_a[15] + bus_b[15] + carry_in_ultimo_bit;
            sig_ovf = un_ovf ^ carry_in_ultimo_bit;
        end

        2'b01: begin // and
            ula_out = bus_a & bus_b;
            un_ovf = 1'b0;
            sig_ovf = 1'b0;
            carry_in_ultimo_bit = 1'b0;
        end

        2'b10: begin // or
            ula_out = bus_a | bus_b;
            un_ovf = 1'b0;
            sig_ovf = 1'b0;
            carry_in_ultimo_bit = 1'b0;
        end

        default: begin // sub
            // tem que fazer ainda

        end
        
        
    endcase
end : ula_ctrl

assign zero = ~|(ula_out);
assign neg = ula_out[15];

always_comb begin : decoder
    a_addr = 'd0;
    b_addr = 'd0;
    c_addr = 'd0;
    mem_addr = 'd0;

    //CODIGOS DO SIMULADOR/INSTRUCTION
    case (instruction[15:8])
        8'b10000001: begin          // LOAD
            decoded_instruction = I_LOAD;
            c_addr = instruction[6:5];
            mem_addr = instruction[4:0];
        end
        8'b10000010: begin          //STORE
            decoded_instruction = I_STORE;
            a_addr = instruction[6:5];
            mem_addr = instruction[4:0];
        end
        8'b10010001: begin          //MOVE
            decoded_instruction = I_MOVE;
            c_addr = instruction[3:2];
            a_addr = instruction[1:0];
            b_addr = instruction[1:0];
            //fazer uma ou no control para se manter igual
        end

        //OPERAÇÕES
        8'b1010000100: begin        // ADD
            decoded_instruction = I_ADD
            a_addr = instruction[1:0];
            b_addr = instruction[3:2];
            c_addr = instruction[5:4];
        end
        8'b1010001000: begin        // SUB
            decoded_instruction = I_SUB
            a_addr = instruction[1:0];
            b_addr = instruction[3:2];
            c_addr = instruction[5:4];
        end
        8'b1010001100: begin        // AND
            decoded_instruction = I_AND
            a_addr = instruction[1:0];
            b_addr = instruction[3:2];
            c_addr = instruction[5:4];
        end
        8'b1010010000: begin        // OR 
            decoded_instruction = I_OR
            a_addr = instruction[1:0];
            b_addr = instruction[3:2];
            c_addr = instruction[5:4];
        end  
        
        //BRANCH'S
        8'b00000001: begin          // BRANCH
            decoded_instruction = I_BRANCH;
            mem_addr = instruction[4:0];
        end
        8'b00000010: begin           // BZERO
            decoded_instruction = I_BZERO;
            mem_addr = instruction[4:0];
        end
        8'b00000011: begin           // BNEG
            decoded_instruction = I_BNEG;
            mem_addr = instruction[4:0];
        end
        8'00000101: begin            // BOV      
            decoded_instruction = I_BOV;
            mem_addr = instruction[4:0];     
        end
        8'00000110: begin            // BNOV       
            decoded_instruction = I_BNOV;
            mem_addr = instruction[4:0];   
        end
        8'00001010: begin            // BNNEG        
            decoded_instruction = I_BNNEG;
            mem_addr = instruction[4:0];  
        end   
        8'00001011: begin           // BNZERO      
            decoded_instruction = I_BNZERO;
            mem_addr = instruction[4:0];
        end
        8'11111111: begin           // HALT
            decoded_instruction = I_HALT; 
        end
        default: begin               //NOP
            decoded_instruction = I_NOP
        end
    endcase
end : decoder

//BANCO DE REGISTRADORES
always @(posedge clk) begin 

    if(!rst_n) begin
            r0 = 15'b000000000000000;
            r1 = 15'b000000000000000;
            r2 = 15'b000000000000000;
            r3 = 15'b000000000000000;
        end
endmodule : data_path
