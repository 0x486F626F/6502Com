reg [8:0] al_A;
reg [7:0] al_B;
reg [4:0] al_O_h;
reg [4:0] al_O_l;
wire [8:0] al_O = {al_O_h, al_O_l[3:0]};
wire adder_carry_in = (alu_shift_right | (alu_op[3:2] == 2'b11))? 0 : carry_in;
wire adder_HC = (alu_bcd & (al_O_l[3:1] >= 3'd5)) | al_O_l[4];
wire adder_carry_out = (alu_bcd & (al_O_h[3:1] >= 3'd5));

always @* begin
    if (alu_shift_right) al_A = {alu_A[0],carry_in,alu_A[7:1]};

    case (alu_op[1:0])
        2'b00: al_A = alu_A | alu_B;
        2'b01: al_A = alu_A & alu_B;
        2'b10: al_A = alu_A ^ alu_B;
        2'b11: al_A = alu_A;
    endcase

    case (alu_op[3:2])
        2'b00: al_B = alu_B;
        2'b01: al_B = ~alu_B;
        2'b10: al_B = al_A;
        2'b11: al_B = 0;
    endcase

    al_O_l = al_A[3:0] + al_B[3:0] + adder_carry_in;
    al_O_h = al_A[8:4] + al_B[7:4] + adder_HC;
    //((alu_bcd & (al_O_l[3:1] >= 3'd5)) | al_O_l[4]);
end

always @(posedge clock)
if (ready) begin
    alu_out <= al_O[7:0];
    carry_out <= al_O[8] | adder_carry_out;
    alu_N <= al_O[7];
    HC <= adder_HC;
end

assign alu_V = alu_A[7] ^ alu_B[7] ^ carry_out ^ alu_N;
assign alu_Z = ~|alu_out;
