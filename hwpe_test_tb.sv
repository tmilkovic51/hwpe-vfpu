`timescale 1ns / 1ps

module hwpe_test_tb();

logic clk, rst_n, clear;
hwpe_stream_intf_stream load;
hwpe_stream_intf_stream store;

flags_fifo_t load_fifo_flags;
flags_fifo_t store_fifo_flags;

ctrl_sourcesink_t  source_stream_ctrl;
flags_sourcesink_t source_stream_flags;

ctrl_sourcesink_t  sink_stream_ctrl;
flags_sourcesink_t sink_stream_flags;

hwpe_test #(
  .DATA_WIDTH(32),
  .NB_TCDM_PORTS(1)
) dut (
  .clk_i(clk),
  .rst_ni(rst_n),
  .clear_i(clear),

  .tcdm_master_load(load),
  .tcdm_master_store(store),

  .load_fifo_flags_o(load_fifo_flags),

  .source_stream_ctrl_i(source_stream_ctrl),
  .source_stream_flags_o(source_stream_flags),

  .sink_stream_ctrl_i(sink_stream_ctrl),
  .sink_stream_flags_o(sink_stream_flags),

  .store_fifo_flags_o(store_fifo_flags)
);


endmodule;
