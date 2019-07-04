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


endmodule