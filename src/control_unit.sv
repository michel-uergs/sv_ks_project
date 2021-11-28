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

// remove from here
// signal added to test environment..
logic [7:0] counter = 'd0;

//process to test environment ... remove this
always @(posedge clk or negedge rst_n) begin
    if (~rst_n)
        counter <= 'd0;
    else
        counter <= counter + 1;
end

assign halt = ( (&(counter)) ? 1'b1 : 1'b0);
//until here !!!!


endmodule : control_unit
