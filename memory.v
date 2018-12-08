module memory #(
    parameter DATA_WIDTH = 8, 
    parameter ADDR_WIDTH = 12
) (
    input  wire clock,
    input  wire wr_en,
    input  wire [ADDR_WIDTH-1:0] addr,
    input  wire [DATA_WIDTH-1:0] din,
    output wire [DATA_WIDTH-1:0] dout
);

reg[DATA_WIDTH-1:0] data [2**ADDR_WIDTH-1:0];

always @(posedge clock)
begin
    if (wr_en) data[addr] <= din;
end

assign dout = data[addr];

endmodule
