always @(posedge clock) begin
    if (ready && wr_reg)
        AXYS[reg_idx] <= (state == JSR0) ? din_mux : {alu_out[7:4]+adj, alu_out[3:0]+adj};

    if (ready && state == DECODE)
        casex (ir)
            8'bxx1xxxx1,8'b1010xxxx,8'b100x10x0,8'bx0xxx01x,8'bxx0xx01x,
            8'b0xxxxxx1,8'bxxx01000,8'b101xx1xx,8'b0xx010xx: ld_reg <= 1;
            default: ld_reg <= 0;
        endcase
end

always @*
    case (state)
        DECODE: wr_reg = ld_reg & ~plp;
        PL1,RTS2,RTI3,BRK3,JSR0,JSR2: wr_reg = 1;
        default wr_reg = 0;
    endcase


