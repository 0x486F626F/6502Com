assign alu_bcd = adc_bcd & (state == FETCH);

always @(posedge clock) begin
    adj_bcd <= adc_sbc & D;

    if (ready && (state == DECODE || state == BRK0))
    casex (ir)
        8'bx11xxx01: adc_sbc <= 1;
        default: adc_sbc <= 0;
    endcase

    if (ready && (state == DECODE || state == BRK0))
    casex (ir)
        8'b011xxx01: adc_bcd <= D;
        default: adc_bcd <= 0;
    endcase;

    if (ready && state == DECODE)
    casex (ir)
        8'b01xxxx10: shift_right <= 1;
        default: shift_right <= 0;
    endcase

    if (state == BRK3) I <= 1;
    else if (state == RTI2) I <= din_mux[2];
    else if (state == REG) begin
        if (sei) I <= 1;
        if (cli) I <= 0;
    end else if (state == DECODE)
    if (plp) I <= alu_out[2];

    case (state)
        WRITE: 
        begin
            N <= alu_N;
            Z <= alu_Z;
            if (shift) C <= carry_out;
        end
        RTI2:
        begin
            N <= din_mux[7];
            V <= din_mux[6];
            D <= din_mux[3];
            Z <= din_mux[1];
            C <= din_mux[0];
        end
        DECODE:
        begin
            if (adc_sbc) V <= alu_V;
            if (clv) V <= 0;

            if (sed) D <= 1;
            if (cld) D <= 0;
            if (plp) begin
                N <= alu_out[7];
                V <= alu_out[6];
                D <= alu_out[3];
                Z <= alu_out[1];
            end begin 
                if ((ld_reg & (reg_idx != idx_S)) | compare) N <= alu_N;
                if ((ld_reg & (reg_idx != idx_S)) | compare | bit_ins) Z <= alu_Z;
            end

            if (~write_back) begin
                if (adc_sbc | shift | compare) C <= carry_out;
                else if (plp) C <= alu_out[0];
                else if (sec) C <= 1;
                else if (clc) C <= 0;
            end
        end
        FETCH:
        begin
            if (bit_ins) begin
                N <= din_mux[7];
                V <= din_mux[6];
            end
        end
    endcase
end

always @* begin
    case (state)
        FETCH,REG,READ: alu_shift_right = shift_right;
        default: alu_shift_right = 0;
    endcase

    case (state)
        REG,zpX0,indX0,absX0,RTI0,RTS0,JSR0,JSR2,BRK0,PL0,indY1,PH0,PH1: alu_A = reg_val;
        JSR1,RTS1,RTI1,RTI2,BRK1,BRK2,indX1: alu_A = alu_out;
        BRA0,READ: alu_A = din_mux;
        BRA1: alu_A = addr_h;
        FETCH: alu_A = load_only ? 0 : reg_val;
        default: alu_A = 0;
    endcase

    case (state)
         READ,REG,BRA1,BRK0,BRK1,BRK2,JSR0,JSR1,JSR2,RTI0,RTI1,RTI2,RTS0,RTS1,
         PH0,PH1,PL0,indX1: alu_B = 8'h00;
         BRA0: alu_B = pc[7:0];
         DECODE,abs1: alu_B = 8'hxx;
         default: alu_B = din_mux;
    endcase

    case (state)
        BRA1,absX1,indY2: carry_in = carry_out;
        READ,REG: carry_in = rotate ? C : shift ? 0 : inc;
        FETCH: carry_in = rotate ? C : compare ? 1 : (shift | load_only)? 0 : C;
        RTI0,RTI1,RTI2,RTS0,RTS1,indX1,indY0: carry_in = 1;
        default: carry_in = 0;
    endcase

    case (state)
        READ: alu_op = op;
        BRA1: alu_op = backwards ? OP_SUB : OP_ADD;
        FETCH,REG: alu_op = op;
        PH1,BRK0,BRK1,BRK2,JSR0,JSR1: alu_op = OP_SUB;
        default: alu_op = OP_ADD;
    endcase
end
