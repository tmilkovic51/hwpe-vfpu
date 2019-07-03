`timescale 1ns / 1ps

import hwpe_ctrl_vfpu_package::*;

module hwpe_test_tb;

logic clk = 0, rst_n, clear;

// VFPU module signals
fp_t                       operandA;
fp_t                       operandB;
fp_t                       result;
  
ctrl_vfpu_t                ctrl_vfpu;
flags_vfpu_t               flags_vfpu;
logic                      operands_valid;
  
logic                      ready;
logic                      valid;

localparam TCP = 10.0ns;

// clock generator
always
    #(TCP/2) clk = !clk;

task reset();
    rst_n <= 0;
    #(4*TCP + TCP/2) rst_n <= 1;
endtask

logic [31:0] a;
logic [31:0] b;
logic [31:0] res;

assign operandA.sign = a[31];
assign operandA.exponent = a[30:23];
assign operandA.mantissa = a[22:0];

assign operandB.sign = b[31];
assign operandB.exponent = b[30:23];
assign operandB.mantissa = b[22:0];

assign res[31] = result.sign;
assign res[30:23] = result.exponent;
assign res[22:0] = result.mantissa;

initial begin
    rst_n = 0;
    clear = 0;
    ctrl_vfpu.operation = FP_OP_SUB;
    ctrl_vfpu.rounding_mode = FP_RM_NEAREST;
    operands_valid = 1'b0;
    
    a = 32'h00000000; // 0.0
    b = 32'h00000000;
    
    #(2*TCP);
    
    rst_n = 1;
    
    #(TCP/2);
    operands_valid = 1'b1;
    a = 32'h41a40000; // 20.5
    b = 32'h408a3d71;// 4.32
    
    #TCP;

    a = 32'h4818e200; // 156 552.0
    b = 32'h40200000;// 2.5
    
    #TCP;

    a = 32'h40b80000; // 5.75
    b = 32'h4311cccd;// 145.8
    
    #TCP;

    a = 32'h3acc78ea; // 0.00156
    b = 32'h44d2f4cd; // 1687.65
    
    #TCP;
    
    operands_valid = 1'b0;
    a = 32'h00000000; // 0.0
    b = 32'h00000000;

    #(10*TCP);
    $finish;
end

vfpu vfpu_engine (
    .clk_i(clk),
    .rst_ni(rst_n),
    
    .operandA_i(operandA),
    .operandB_i(operandB),
    .result_o(result),
    
    .ctrl_vfpu_i(ctrl_vfpu),
    .flags_vfpu_o(flags_vfpu),
    
    .operands_valid_i(operands_valid),
    .ready_o(ready),
    .done_o(valid)
);

endmodule
