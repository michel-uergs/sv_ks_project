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
logic [15:0]    r0;
logic [15:0]    r1;
logic [15:0]    r2;
logic [15:0]    r3;
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

always_ff @(posedge clk or negedge rst_n) begin : pc_ctrl
    if (!rst_n)begin
        program_counter <= 'd0;
    end
    else
        if (pc_enable) begin
            if (branch) 
                program_counter <= mem_addr;
            else
                program_counter <= program_counter + 1;
        end
end : pc_ctrl

always_comb begin : ula_ctrl
    case (operation)

        2'b00: begin // or
            ula_out = bus_a | bus_b;
            un_ovf = 1'b0;
            sig_ovf = 1'b0;
            carry_in_ultimo_bit = 1'b0;
        end

        2'b01: begin // add
            {carry_in_ultimo_bit,ula_out[14:0]} = bus_a[14:0] + bus_b[14:0];
            {un_ovf, ula_out[15]} = bus_a[15] + bus_b[15] + carry_in_ultimo_bit;
            sig_ovf = un_ovf ^ carry_in_ultimo_bit;
        end

        2'b10: begin // sub
            assign bus_b = ~(bus_b) + 1;
            {carry_in_ultimo_bit,ula_out[14:0]} = bus_a[14:0] + bus_b[14:0];
            {un_ovf, ula_out[15]} = bus_a[15] + bus_b[15] + carry_in_ultimo_bit;
            sig_ovf = un_ovf ^ carry_in_ultimo_bit;
            
        end

        default: begin // and         
            ula_out = bus_a & bus_b;
            un_ovf = 1'b0;
            sig_ovf = 1'b0;
            carry_in_ultimo_bit = 1'b0;

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

        //OPERAÃƒâ€¡Ãƒâ€¢ES
        8'b10100001: begin        // ADD
            decoded_instruction = I_ADD;
            a_addr = instruction[1:0];
            b_addr = instruction[3:2];
            c_addr = instruction[5:4];
        end
        8'b10100010: begin        // SUB
            decoded_instruction = I_SUB;
            a_addr = instruction[1:0];
            b_addr = instruction[3:2];
            c_addr = instruction[5:4];
        end
        8'b10100011: begin        // AND
            decoded_instruction = I_AND;
            a_addr = instruction[1:0];
            b_addr = instruction[3:2];
            c_addr = instruction[5:4];
        end
        8'b10100100: begin        // OR 
            decoded_instruction = I_OR;
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
        8'b00000101: begin            // BOV      
            decoded_instruction = I_BOV;
            mem_addr = instruction[4:0];     
        end
        8'b00000110: begin            // BNOV       
            decoded_instruction = I_BNOV;
            mem_addr = instruction[4:0];   
        end
        8'b00001010: begin            // BNNEG        
            decoded_instruction = I_BNNEG;
            mem_addr = instruction[4:0];  
        end   
        8'b00001011: begin           // BNZERO      
            decoded_instruction = I_BNZERO;
            mem_addr = instruction[4:0];
        end
        8'b11111111: begin           // HALT
            decoded_instruction = I_HALT; 
        end
        default: begin               //NOP
            decoded_instruction = I_NOP;
        end
    endcase
end : decoder

//BANCO DE REGISTRADORES
always_ff @(posedge clk or negedge rst_n) begin 
    if(write_reg_enable) begin
      case(a_addr)
        2'b00:
            bus_a = r0;  
         2'b01:
            bus_a = r1;  
         2'b10:
            bus_a = r2;
         2'b11:
            bus_a = r3;
    endcase
  end
     case(b_addr)
         2'b00:
            bus_b = r0;  
         2'b01:
            bus_b = r1;  
         2'b10:
            bus_b = r2;
         2'b11:
            bus_b = r3;  
        endcase      
    case(c_addr)
         2'b00:
            r0 = bus_c;  
         2'b01:
            r1 = bus_c;  
         2'b10:
            r2 = bus_c;
         2'b11:
            r3 = bus_c;
     endcase 
end
// MUXs

assign bus_c = c_sel ? ula_out : data_in;
assign ram_addr = addr_sel ? program_counter : mem_addr;
    
 
always_ff @(posedge clk ) begin : flags_reg
    if (flags_reg_enable) begin
        zero_op <=  zero;
        neg_op <= neg;
        unsigned_overflow <= un_ovf; 
        signed_overflow <= sig_ovf;
    end
end

endmodule : data_path
