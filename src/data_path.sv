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
    logic [4:0] program_counter;
    logic [4:0] branch_out;
    logic [4:0] mem_addr;
    logic [15:0] instruction;

    logic [1:0] a_addr;
    logic [1:0] b_addr;
    logic [1:0] c_addr;

    logic [15:0] r0;
    logic [15:0] r1;
    logic [15:0] r2;
    logic [15:0] r3;

    logic [15:0] bus_a;
    logic [15:0] bus_b;
    logic [15:0] bus_c;
    logic [15:0] ula_out;

    logic flag_zero;
    logic flag_neg;
    logic flag_unsigned;
    logic flag_signed;

endmodule : data_path
