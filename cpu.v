module cpu6502 (
    input  wire        clock,
    input  wire [7:0]  din,
    input  wire        ready,
    input  wire        irq,
    input  wire        nmi,
    input  wire        reset,
    output reg         wr_en,
    output reg  [7:0]  dout,
    output reg  [15:0] addr
);

reg rotate;
reg shift;
reg compare;
reg inc;
reg nmi_edge;
reg nmi_hold;
reg store;
reg write_back;
reg backwards;
reg load_only;
reg cond_true;
reg adj_bcd;
reg adc_bcd;
reg adc_sbc;
reg wr_reg;
reg ld_reg;
reg reg_y;
reg bit_ins;
reg res;

reg php;
reg clc;
reg plp;
reg sec;
reg cli;
reg sei;
reg clv;
reg cld;
reg sed;

reg [7:0] AXYS[3:0];
reg [7:0] state;
reg [1:0] reg_idx;
reg [1:0] src_reg;
reg [1:0] dst_reg;
reg N;
reg V;
reg D;
reg I;
reg Z;
reg C;
wire [7:0] sr_flags = {N, V, 2'b11, D, I, Z, C};
wire [7:0] reg_val = AXYS[reg_idx];

reg        ir_hold_valid;
reg  [7:0] ir_hold;
wire [7:0] ir;
reg  [7:0] din_hold;
wire [7:0] din_mux;

reg [15:0] pc, pc_mux;
reg pc_inc;

reg [7:0]  addr_l;
reg [7:0]  addr_h;
reg [3:0]  adj;

reg [3:0] op;
reg [3:0] alu_op;
reg [7:0] alu_A;
reg [7:0] alu_B;
reg carry_in;
reg shift_right;
reg alu_shift_right;
reg HC;
reg [7:0] alu_out;
reg carry_out;
reg alu_N;
wire alu_V;
wire alu_Z;
wire alu_bcd;

parameter idx_A = 2'b00;
parameter idx_X = 2'b01;
parameter idx_Y = 2'b10;
parameter idx_S = 2'b11;

parameter OP_ADD    = 4'b0011;
parameter OP_SUB    = 4'b0111;
parameter OP_ROL    = 4'b1011;
parameter OP_OR     = 4'b1100;
parameter OP_AND    = 4'b1101;
parameter OP_EOR    = 4'b1110;
parameter OP_A      = 4'b1111;

parameter ZEROPAGE  = 8'h00;
parameter STACKPAGE = 8'h01;

parameter FETCH  = 8'b00000000;
parameter DECODE = 8'b00001000;
parameter REG    = 8'b00010000;
parameter READ   = 8'b00011000;
parameter WRITE  = 8'b00100000;
parameter abs0   = 8'b00101000;
parameter abs1   = 8'b00101001;
parameter absX0  = 8'b00110000;
parameter absX1  = 8'b00110001;
parameter absX2  = 8'b00110010;
parameter indX0  = 8'b00111000;
parameter indX1  = 8'b00111001;
parameter indX2  = 8'b00111010;
parameter indX3  = 8'b00111011;
parameter indY0  = 8'b01000000;
parameter indY1  = 8'b01000001;
parameter indY2  = 8'b01000010;
parameter indY3  = 8'b01000011;
parameter zp0    = 8'b01001000;
parameter zpX0   = 8'b01010000;
parameter zpX1   = 8'b01010001;
parameter BRA0   = 8'b01011000;
parameter BRA1   = 8'b01011001;
parameter BRA2   = 8'b01011010;
parameter BRK0   = 8'b01100000;
parameter BRK1   = 8'b01100001;
parameter BRK2   = 8'b01100010;
parameter BRK3   = 8'b01100011;
parameter JSR0   = 8'b01101000;
parameter JSR1   = 8'b01101001;
parameter JSR2   = 8'b01101010;
parameter JSR3   = 8'b01101011;
parameter JMPa0  = 8'b01110000;
parameter JMPa1  = 8'b01110001;
parameter JMPi0  = 8'b01111000;
parameter JMPi1  = 8'b01111001;
parameter RTI0   = 8'b10000000;
parameter RTI1   = 8'b10000001;
parameter RTI2   = 8'b10000010;
parameter RTI3   = 8'b10000011;
parameter RTI4   = 8'b10000100;
parameter RTS0   = 8'b10001000;
parameter RTS1   = 8'b10001001;
parameter RTS2   = 8'b10001010;
parameter RTS3   = 8'b10001011;
parameter PH0    = 8'b10010000;
parameter PH1    = 8'b10010001;
parameter PL0    = 8'b10011000;
parameter PL1    = 8'b10011001;
parameter PL2    = 8'b10011010;

`include "cpu/data_in.v"
`include "cpu/data_out.v"
`include "cpu/state_machine.v"
`include "cpu/control_signal.v"
`include "cpu/pc.v"
`include "cpu/register.v"
`include "cpu/alu_control.v"
`include "cpu/alu.v"

always @(posedge clock) begin
    $display("--------------------");
    $display("State: %b", state);
    $display("ready: %b, irq: %b, nmi: %b, reset: %b", ready, irq, nmi, reset);
    $display("Data In: %h", din);
    $display("wr_en: %b, addr: %h, Data Out: %h", wr_en, addr, dout);
    $display("PC: %h, IR: %h %b", pc, ir, ir); 
    $display("A: %h, X: %h, Y: %h, S: %h", AXYS[0], AXYS[1], AXYS[2], AXYS[3]);
    $display("====================");
end

endmodule
