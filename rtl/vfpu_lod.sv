`timescale 1ns / 1ps

import hwpe_stream_package::*;
import hwpe_ctrl_package::*;
import hwpe_ctrl_vfpu_package::*;

module vfpu_lod
#(
  parameter WIDTH = 32
)
(
  input  logic [WIDTH-1:0]         in_i,

  output logic [$clog2(WIDTH)-1:0] first_one_o,
  output logic                     no_ones_o
);



always_comb
begin
first_one_o = 0;
   for (int i = 0; i < WIDTH; i++)
   begin
      if (in_i[i])
      begin
         first_one_o = WIDTH-1-i;
      end
   end
end

assign no_ones_o = ~(| in_i);

/*
  localparam NUM_LEVELS = $clog2(WIDTH);

  logic [WIDTH-1:0] [NUM_LEVELS-1:0]         index_lut;
  logic [2**NUM_LEVELS-1:0]                  sel_nodes;
  logic [2**NUM_LEVELS-1:0] [NUM_LEVELS-1:0] index_nodes;

  logic [WIDTH-1:0]                          in_flipped;


  //////////////////////////////////////////////////////////////////////////////
  // generate tree structure                                                  //
  //////////////////////////////////////////////////////////////////////////////

  generate
    genvar j;
    for (j = 0; j < WIDTH; j++) begin
      assign index_lut[j] = $unsigned(j);
      assign in_flipped[j] = in_i[WIDTH-j-1];
    end
  endgenerate

  generate
    genvar k;
    genvar l;
    genvar level;
    for (level = 0; level < NUM_LEVELS; level++) begin
    //------------------------------------------------------------
    if (level < NUM_LEVELS-1) begin
      for (l = 0; l < 2**level; l++) begin
        assign sel_nodes[2**level-1+l]   = sel_nodes[2**(level+1)-1+l*2] | sel_nodes[2**(level+1)-1+l*2+1];
        assign index_nodes[2**level-1+l] = (sel_nodes[2**(level+1)-1+l*2] == 1'b1) ?
                                           index_nodes[2**(level+1)-1+l*2] : index_nodes[2**(level+1)-1+l*2+1];
      end
    end
    //------------------------------------------------------------
    if (level == NUM_LEVELS-1) begin
      for (k = 0; k < 2**level; k++) begin
        // if two successive indices are still in the vector...
        if (k * 2 < WIDTH-1) begin
          assign sel_nodes[2**level-1+k]   = in_flipped[k*2] | in_flipped[k*2+1];
          assign index_nodes[2**level-1+k] = (in_flipped[k*2] == 1'b1) ? index_lut[k*2] : index_lut[k*2+1];
        end
        // if only the first index is still in the vector...
        if (k * 2 == WIDTH-1) begin
          assign sel_nodes[2**level-1+k]   = in_flipped[k*2];
          assign index_nodes[2**level-1+k] = index_lut[k*2];
        end
        // if index is out of range
        if (k * 2 > WIDTH-1) begin
          assign sel_nodes[2**level-1+k]   = 1'b0;
          assign index_nodes[2**level-1+k] = '0;
        end
      end
    end
    //------------------------------------------------------------
    end
  endgenerate

  //////////////////////////////////////////////////////////////////////////////
  // connect output                                                           //
  //////////////////////////////////////////////////////////////////////////////

  assign first_one_o = index_nodes[0];
  assign no_ones_o         = ~sel_nodes[0];
  
*/
endmodule