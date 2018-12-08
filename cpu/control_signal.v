always @(posedge clock) begin 
    // NMI
    nmi_hold <= nmi;
    if (nmi_edge && state == BRK3) nmi_edge <= 0;
    else if (nmi & ~nmi_hold) nmi_edge <= 1;


    if (ready) begin
        backwards <= din_mux[7];

        case (ir[7:5])
            3'b000: cond_true = ~N;
            3'b001: cond_true = N;
            3'b010: cond_true = ~V;
            3'b011: cond_true = V;
            3'b100: cond_true = ~C;
            3'b101: cond_true = C;
            3'b110: cond_true = ~Z;
            3'b111: cond_true = Z;
        endcase
    end

    if (state == DECODE && ready) begin
        php <= (ir == 8'h08);
        clc <= (ir == 8'h18);
        plp <= (ir == 8'h28);
        sec <= (ir == 8'h38);
        cli <= (ir == 8'h58);
        sei <= (ir == 8'h78);
        clv <= (ir == 8'hb8);
        cld <= (ir == 8'hd8);
        sed <= (ir == 8'hf8);

        casex (ir)
            8'b00xxxx10: op <= OP_ROL;
            8'b0010x100: op <= OP_AND;
            8'b01xxxx10: op <= OP_A;
            8'b11x00x0x,8'b11xxx10x,8'b11xxxxx1,8'b1000100x,8'b110xxx1x: op <= OP_SUB;
            8'b010xxx01,8'b00xxxx01: op <= {2'b11,ir[6:5]};
            default: op <= OP_ADD;
        endcase

        casex (ir)
            8'b0010x100: bit_ins <= 1;
            default: bit_ins <= 0;
        endcase

        casex (ir)
            8'b100xx1x0,8'b100xxx01: store <= 1;
            default: store <= 0;
        endcase

        casex (ir)
            8'b0xxxx110,8'b11xxx110: write_back <= 1;
            default: write_back <= 0;
        endcase

        casex (ir)
            8'bxxx1x0x1,8'b10x1x11x,8'bxxxx10x1: reg_y <= 1;
            default: reg_y <= 0;
        endcase

        casex (ir)
            8'b101xxxxx: load_only <= 1;
            default: load_only <= 0;
        endcase

        casex (ir)
            8'b0x1x1010,8'b0x1xx110: rotate <= 1;
            default: rotate <= 0;
        endcase

        casex (ir)
            8'b0xxxx110,8'b0xxx1010: shift <= 1;
            default: shift <= 0;
        endcase

        casex (ir)
            8'b11xxx100,8'b11x00x00,8'b110xxxx1: compare <= 1;
            default: compare <= 0;
        endcase

        casex (ir)
            8'b111xx110,8'b11x01000: inc <= 1;
            default: inc <= 0;
        endcase;

        casex (ir)
            8'b1x0xx01x,8'b1110xx00,8'b100xxx1x: src_reg <= idx_X;
            8'b1x00xx00,8'b100x1x00,8'b1x0xx100: src_reg <= idx_Y;
            8'b10111010: src_reg <= idx_S;
            default: src_reg <= idx_A;
        endcase

        casex (ir)
            8'b11101000,8'b101xxx1x,8'b110xx01x: dst_reg <= idx_X;
            8'b1x001000,8'bxx11x100,8'b1010xx00: dst_reg <= idx_Y;
            8'bxx01x01x,8'b0x001000: dst_reg <= idx_S;
            default: dst_reg <= idx_A;
        endcase
    end

    if (reset) res <= 1;
    else if (state == DECODE) res <= 0;

    if (ready && state[7:3] != 5'b10010 && state[7:3] != 5'b10011) begin
        addr_l <= addr[7:0];
        addr_h <= addr[15:8];
    end
end

always @* begin
    case (state) 
        DECODE: reg_idx = dst_reg;
        absX0,indX0,indY0,zpX0: reg_idx = reg_y ? idx_Y : idx_X;
        BRK0,BRK3,JSR0,JSR2,PL0,PL1,PH1,RTI0,RTI3,RTS0,RTS2: reg_idx = idx_S;
        default: reg_idx = src_reg;
    endcase

    casex ({adj_bcd, adc_bcd, HC})
        3'b100: adj = 4'd10;
        3'b111: adj = 4'd6;
        default: adj = 4'd0;
    endcase 
end
