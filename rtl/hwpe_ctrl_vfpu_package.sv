package hwpe_ctrl_vfpu_package;

//======================================================//
//         CONFIGURATION REGISTERS PARAMETERS           //
//======================================================//

  // OPERAND A CONTROL REGISTERS INDICES
  parameter int unsigned BASE_ADDR_A_REG_INDEX              = 0;
  parameter int unsigned LINE_STRIDE_A_REG_INDEX            = 1;
  parameter int unsigned LINE_LENGTH_A_REG_INDEX            = 1;
  parameter int unsigned FEAT_STRIDE_A_REG_INDEX            = 2;
  parameter int unsigned FEAT_LENGTH_A_REG_INDEX            = 2;
  parameter int unsigned LOOP_OUTER_A_REG_INDEX             = 3;
  parameter int unsigned FEAT_ROLL_A_REG_INDEX              = 3;

  // OPERAND B CONTROL REGISTERS INDICES
  parameter int unsigned BASE_ADDR_B_REG_INDEX              = 4;
  parameter int unsigned LINE_STRIDE_B_REG_INDEX            = 5;
  parameter int unsigned LINE_LENGTH_B_REG_INDEX            = 5;
  parameter int unsigned FEAT_STRIDE_B_REG_INDEX            = 6;
  parameter int unsigned FEAT_LENGTH_B_REG_INDEX            = 6;
  parameter int unsigned LOOP_OUTER_B_REG_INDEX             = 7;
  parameter int unsigned FEAT_ROLL_B_REG_INDEX              = 7;

  // RESULT CONTROL REGISTERS INDICES
  parameter int unsigned BASE_ADDR_RESULT_REG_INDEX         = 8;
  parameter int unsigned LINE_STRIDE_RESULT_REG_INDEX       = 9;
  parameter int unsigned LINE_LENGTH_RESULT_REG_INDEX       = 9;
  parameter int unsigned FEAT_STRIDE_RESULT_REG_INDEX       = 10;
  parameter int unsigned FEAT_LENGTH_RESULT_REG_INDEX       = 10;
  parameter int unsigned LOOP_OUTER_RESULT_REG_INDEX        = 11;
  parameter int unsigned FEAT_ROLL_RESULT_REG_INDEX         = 11;

  // COMMON CONTROL REGISTER INDICES
  parameter int unsigned TRANSACTION_SIZE_REG_INDEX         = 12;
  parameter int unsigned OPERATION_SELECT_REG_INDEX         = 13;
  parameter int unsigned ROUNDING_MODE_SELECT_REG_INDEX     = 13;
  
  // SIGNAL WIDTHS IN BITS
  parameter int unsigned OPERATION_SELECT_WIDTH             = 3;
  parameter int unsigned ROUNDING_MODE_SELECT_WIDTH         = 2;
  
  
//======================================================//
//           FLOATING POINT FRAGMENTS WIDTHS            //
//======================================================//
  parameter int unsigned FP_WIDTH               = 32;

  parameter int unsigned FP_SIGN_WIDTH          = 1;
  parameter int unsigned FP_EXP_WIDTH           = 8;
  parameter int unsigned FP_MAN_WIDTH           = 23;
  
  
//======================================================//
//              FLOATING POINT CONSTANTS                //
//======================================================//
  // Exponent bias
  parameter EXP_BIAS            = 10'd127;
  
  // Special values
  parameter QNAN                = 32'hFFC00001;
  parameter SNAN                = 32'hFF800001;
  parameter MINUS_INFINITY      = 32'hFF800000;
  parameter PLUS_INFINITY       = 32'h7F800000;
  
//======================================================//
//                   TYPE DEFINITIONS                   //
//======================================================//

  // VFPU control signals structure
  typedef struct packed {
    logic [OPERATION_SELECT_WIDTH-1:0]      operation;
    logic [ROUNDING_MODE_SELECT_WIDTH-1:0]  rounding_mode;
  } ctrl_vfpu_t;
  
  // VFPU flags structure
  typedef struct packed {
    logic               underflow;
    logic               overflow;
    logic               inexact;
    logic               zero;
    logic               plusInfinity;
    logic               minusInfinity;
  } flags_vfpu_t;
  
  // floating point number format
  typedef struct packed {
    logic                       sign;
    logic [FP_EXP_WIDTH-1:0]    exponent;
    logic [FP_MAN_WIDTH-1:0]    mantissa;
  } fp_t;

endpackage // hwpe_ctrl_vfpu_package
