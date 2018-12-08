module rom (
    input  wire        cpu_clock,
    input  wire        cpu_wr_en,
    input  wire [15:0] cpu_addr,
    input  wire  [7:0] cpu_din,
    output wire  [7:0] cpu_dout,

    input  wire        ppu_clock,
    input  wire        ppu_wr_en,
    input  wire [15:0] ppu_addr,
    input  wire  [7:0] ppu_din,
    output wire  [7:0] ppu_dout
);

reg [7:0] header[0:15];
reg [7:0] char;
integer nesfile, status, i, size;

reg  [7:0] prgrom[0:2**15-1];
wire [7:0] prgrom_dout;
wire [7:0] prgram_dout;

reg  [7:0] chrrom[0:2**13-1];
wire [7:0] chrrom_dout;

memory #(
    .DATA_WIDTH(8),
    .ADDR_WIDTH(14)
) prgram (
    .clock(cpu_clock),
    .wr_en(cpu_wr_en & ~cpu_addr[15]),
    .addr(cpu_addr[13:0]),
    .din(cpu_din),
    .dout(prgram_dout)
);

assign prgrom_dout = (header[4] == 2)? 
prgrom[cpu_addr[14:0]] : prgrom[{1'b0, cpu_addr[13:0]}];

assign cpu_dout = cpu_addr[15]  ? prgrom_dout : prgram_dout;

assign chrrom_dout = chrrom_dout[ppu_addr[12:0]];

initial begin
    nesfile = $fopen("rom.nes", "rb");
    for (i = 0; i < 16; i ++) begin
        char = $fgetc(nesfile);
        header[i] = char;
    end
    $display("PRG ROM size: %d*16kb", header[4]);
    $display("CHR ROM size: %d*8kb", header[5]);
    size = (2**14) * header[4];
    for (i = 0; i < size; i ++) begin
        char = $fgetc(nesfile);
        prgrom[i] = char;
    end
    $display("MMI    : %h%h", prgrom[16384*header[4]-5],prgrom[16384*header[4]-6]);
    $display("Reset  : %h%h", prgrom[16384*header[4]-3],prgrom[16384*header[4]-4]);
    $display("IRQ/BRK: %h%h", prgrom[16384*header[4]-1],prgrom[16384*header[4]-2]);
    size = (2**13) * header[5];
    for (i = 0; i < size; i ++) begin
        char = $fgetc(nesfile);
        chrrom[i] = char;
    end
end

endmodule
