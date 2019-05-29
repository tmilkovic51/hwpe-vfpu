`define NB_TCDM_PORTS 3

import hwpe_stream_package::*;
import hwpe_ctrl_package::*;

module hwpe_top_wrap
#(
  parameter int unsigned N_CORES = 2,
  parameter int unsigned ID_WIDTH = 16,
  parameter int unsigned DATA_WIDTH = 32
)
(
  input  logic                  clk,
  input  logic                  rst_n,

  output logic [N_CORES-1:0][REGFILE_N_EVT-1:0] evt,
  
  output logic [`NB_TCDM_PORTS-1:0]       tcdm_req,
  input  logic [`NB_TCDM_PORTS-1:0]       tcdm_gnt,
  output logic [`NB_TCDM_PORTS-1:0][31:0] tcdm_add,
  output logic [`NB_TCDM_PORTS-1:0]       tcdm_wen,
  output logic [`NB_TCDM_PORTS-1:0][3:0]  tcdm_be,
  output logic [`NB_TCDM_PORTS-1:0][31:0] tcdm_data,
  input  logic [`NB_TCDM_PORTS-1:0][31:0] tcdm_r_data,
  input  logic [`NB_TCDM_PORTS-1:0]       tcdm_r_valid,

  input  logic                periph_req,
  output logic                periph_gnt,
  input  logic [31:0]         periph_add,
  input  logic                periph_wen,
  input  logic [3:0]          periph_be,
  input  logic [31:0]         periph_data,
  input  logic [ID_WIDTH-1:0] periph_id,
  output logic [31:0]         periph_r_data,
  output logic                periph_r_valid,
  output logic [ID_WIDTH-1:0] periph_r_id
);

  hwpe_stream_intf_tcdm
    tcdm[`NB_TCDM_PORTS] ( clk );
  
  hwpe_ctrl_intf_periph #( DATA_WIDTH )
    periph ( clk );

  genvar i;
  for (i = 0; i < `NB_TCDM_PORTS; i++) begin
      assign tcdm_req[i] = tcdm[i].req;
      assign tcdm_add[i] = tcdm[i].add;
      assign tcdm_wen[i] = tcdm[i].wen;
      assign tcdm_be[i] = tcdm[i].be;
      assign tcdm_data[i] = tcdm[i].data;
      assign tcdm[i].gnt = tcdm_gnt[i];
      assign tcdm[i].r_data = tcdm_r_data[i];
      assign tcdm[i].r_valid = tcdm_r_valid[i];
  end

  assign periph.req = periph_req;
  assign periph.add = periph_add;
  assign periph.wen = periph_wen;
  assign periph.be = periph_be;
  assign periph.data = periph_data;
  assign periph.id = periph_id;
  assign periph_gnt = periph.gnt;
  assign periph_r_data = periph.r_data;
  assign periph_r_valid = periph.r_valid;
  assign periph_r_id = periph.r_id;

  hwpe_top #(
    .N_CORES(N_CORES),
    .ID_WIDTH(ID_WIDTH),
    .DATA_WIDTH(DATA_WIDTH)
  ) hwpe_top_inst (
    .clk(clk),
    .rst_n(rst_n),
    .evt(evt),
    .tcdm(tcdm),
    .slave_config_interface(tcdm)
  );

endmodule
