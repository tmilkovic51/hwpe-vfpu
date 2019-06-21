`timescale 1ns / 1ps

module hwpe_test_tb;

logic clk=0, rst_n, clear;
logic randomize_i;

hwpe_stream_intf_tcdm load[0:0] (
  .clk ( clk )
);

hwpe_stream_intf_tcdm store (
  .clk ( clk )
);

flags_fifo_t load_fifo_flags;
flags_fifo_t store_fifo_flags;

ctrl_sourcesink_t  source_stream_ctrl;
flags_sourcesink_t source_stream_flags;

ctrl_sourcesink_t  sink_stream_ctrl;
flags_sourcesink_t sink_stream_flags;

localparam TCP = 10.0ns;

always
    #(TCP/2) clk = !clk;

task reset();
    #TCP rst_n <= 0;
    #(4*TCP) rst_n <= 1;
endtask

initial begin
    randomize_i = 1;
    #TCP randomize_i = 0;
    reset();

    store.gnt = 1;

    source_stream_ctrl.addressgen_ctrl.base_addr = 0;
    source_stream_ctrl.addressgen_ctrl.trans_size = 3;
    source_stream_ctrl.addressgen_ctrl.line_stride = 12;
    source_stream_ctrl.addressgen_ctrl.line_length = 1;
    source_stream_ctrl.addressgen_ctrl.feat_stride = 0;
    source_stream_ctrl.addressgen_ctrl.feat_length = 3;
    source_stream_ctrl.addressgen_ctrl.feat_roll = 1;
    source_stream_ctrl.addressgen_ctrl.loop_outer = 0;
    source_stream_ctrl.addressgen_ctrl.realign_type = 0;
    source_stream_ctrl.addressgen_ctrl.line_length_remainder = 0;

    sink_stream_ctrl.addressgen_ctrl.base_addr = 0;
    sink_stream_ctrl.addressgen_ctrl.trans_size = 3;
    sink_stream_ctrl.addressgen_ctrl.line_stride = 12;
    sink_stream_ctrl.addressgen_ctrl.line_length = 1;
    sink_stream_ctrl.addressgen_ctrl.feat_stride = 0;
    sink_stream_ctrl.addressgen_ctrl.feat_length = 3;
    sink_stream_ctrl.addressgen_ctrl.feat_roll = 1;
    sink_stream_ctrl.addressgen_ctrl.loop_outer = 0;
    sink_stream_ctrl.addressgen_ctrl.realign_type = 0;
    sink_stream_ctrl.addressgen_ctrl.line_length_remainder = 0;

    source_stream_ctrl.req_start = 1;
    sink_stream_ctrl.req_start = 1;

    #TCP source_stream_ctrl.req_start = 0;
    #TCP sink_stream_ctrl.req_start = 0;    

    #(40*TCP) $finish;
end

hwpe_test #(
  .DATA_WIDTH(32),
  .NB_TCDM_PORTS(1)
) dut (
  .clk_i(clk),
  .rst_ni(rst_n),
  .clear_i(clear),

  .tcdm_master_load(load[0]),
  .tcdm_master_store(store),

  .load_fifo_flags_o(load_fifo_flags),

  .source_stream_ctrl_i(source_stream_ctrl),
  .source_stream_flags_o(source_stream_flags),

  .sink_stream_ctrl_i(sink_stream_ctrl),
  .sink_stream_flags_o(sink_stream_flags),

  .store_fifo_flags_o(store_fifo_flags)
);

tb_dummy_memory #(
  .MP(1),
  .MEMORY_SIZE(128),
  .BASE_ADDR(0),
  .PROB_STALL(0.1),
  .TCP(TCP),
  .TA(0.2ns),
  .TT(0.8ns),
  .INSTRUMENTATION(0)
) dummy_memory_i (
  .clk_i(clk),
  .randomize_i(randomize_i),
  .enable_i(1),
  .tcdm(load)
);

endmodule
