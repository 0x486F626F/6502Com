/*
0000 0000 0000 0000 - 0000 0111 1111 1111 RAM
0000 1000 0000 0000 - 0000 1111 1111 1111 RAM Mirror
0001 0000 0000 0000 - 0001 0111 1111 1111 RAM Mirror
0001 1000 0000 0000 - 0001 1111 1111 1111 RAM Mirror
0010 0000 0000 0000 - 0010 0000 0000 0111 PPU Reg
0010 0000 0000 1000 - 0011 1111 1111 1111 PPU Reg Mirror
0100 0000 0000 0000 - 0100 0000 0001 0111 APU and I/O
0100 0000 0001 1000 - 0100 0000 0001 1111 disabled
0100 0000 0010 0000 - 1111 1111 1111 1111 cartridge
*/

module com (
    input wire cpu_clock
);

parameter time_int = 100;

reg cpu_ready;
reg reset;
reg has_reset;

wire        cpu_wr_en;
wire        cpu_irq;
wire        cpu_nmi;
wire [15:0] cpu_addr;
wire [15:0] bus_addr;
reg  [7:0]  cpu_din;
wire [7:0]  cpu_dout;

wire        ram_wr_en;
wire [11:0] ram_addr;
wire  [7:0] ram_din;
wire  [7:0] ram_dout;

wire        rom_cpu_wr_en;
wire [15:0] rom_cpu_addr;
wire  [7:0] rom_cpu_din;
wire  [7:0] rom_cpu_dout;

reg         dma_en;
reg   [7:0] dma_addr_hi;
reg   [7:0] dma_addr_lo;
wire  [7:0] dma_dout;

wire [1:0] addr_mod;

parameter RAM_ADDR_MOD = 0;
parameter ROM_ADDR_MOD = 1;

assign bus_addr = dma_en ? {dma_addr_hi,dma_addr_lo} : cpu_addr;

assign addr_mod = (bus_addr[15:13] == 3'b000) ? RAM_ADDR_MOD : ROM_ADDR_MOD;

always @(posedge cpu_clock)
    if (addr_mod == RAM_ADDR_MOD) cpu_din <= ram_dout;
    else cpu_din <= rom_cpu_dout;

cpu6502 cpu(
    .clock(cpu_clock),
    .din(cpu_din),
    .ready(cpu_ready & ~dma_en),
    .irq(cpu_irq),
    .nmi(cpu_nmi),
    .reset(reset),
    .wr_en(cpu_wr_en),
    .dout(cpu_dout),
    .addr(cpu_addr)
);

assign ram_wr_en = addr_mod == RAM_ADDR_MOD? cpu_wr_en : 0;
assign ram_addr = bus_addr[11:0];
assign ram_din = cpu_dout;

memory #(
    .DATA_WIDTH(8),
    .ADDR_WIDTH(12)
)ram(
    .clock(cpu_clock),
    .wr_en(ram_wr_en),
    .addr(ram_addr),
    .din(ram_din),
    .dout(ram_dout)
);

assign rom_cpu_wr_en = addr_mod == ROM_ADDR_MOD? cpu_wr_en : 0;
assign rom_cpu_addr = bus_addr;
assign rom_cpu_din = cpu_dout;

rom rom(
    .cpu_clock(cpu_clock),
    .cpu_wr_en(rom_cpu_wr_en),
    .cpu_addr(rom_cpu_addr),
    .cpu_din(rom_cpu_din),
    .cpu_dout(rom_cpu_dout)
);


always @(posedge cpu_clock) begin
    if (has_reset == 0) begin
        reset <= 1;
        has_reset <= 1;
    end
    if (reset) begin
        reset <= 0;
        cpu_ready <= 1;
    end
end

initial begin
    reset = 0;
    has_reset = 0;
    cpu_ready = 0;
end 

always @(posedge cpu_clock) begin
    for (int i = 0; i < 256; i ++)
        if (i % 16 == 15) $write("%02h\n", ram.data[16'h0200+i]);
        else $write("%02h ", ram.data[16'h0200+i]);
end


endmodule
