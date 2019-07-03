`timescale 1ns / 1ps


module vfpu_lod_tb;

localparam int unsigned WIDTH = 48;
localparam TCP = 10.0ns;


logic clk = 0;
logic [WIDTH-1:0]         in;
logic [$clog2(WIDTH)-1:0] first_one;
logic                     no_ones;




// clock generator
always
    #(TCP/2) clk = !clk;



initial begin
    
    in = 48'h0F00F00FF0F0;
    
    #TCP;
    
    in = 48'h8000F00FF0F0;
    
    #TCP;
    
    in = 48'h000000000001;
    
    $finish;
end

vfpu_lod 
#(
  .WIDTH(WIDTH)
) lod (
  .in_i(in),
  .first_one_o(first_one),
  .no_ones_o(no_ones)
);

endmodule
