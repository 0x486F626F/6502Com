always @* begin
    // WE
    case (state)
        BRK0,BRK1,BRK2,JSR0,JSR1,PH1,WRITE: wr_en = 1;
        indX3,indY3,absX2,abs1,zpX1,zp0: wr_en = store;
        default: wr_en = 0;
    endcase

    // dout
    case (state)
        WRITE: dout = alu_out;
        JSR0,BRK0: dout = pc[15:8];
        JSR1,BRK1: dout = pc[7:0];
        PH1: dout = php ? sr_flags : alu_out;
        BRK2: dout = (irq | nmi_edge) ? (sr_flags & 8'b11101111) : sr_flags;
        default: dout = reg_val;
    endcase

    // addr
    case (state)
        absX1,indX3,indY2,JMPa1,JMPi1,RTI4,abs1: addr = {din_mux,alu_out};
        BRA2,indY3,absX2: addr = {alu_out,addr_l};
        BRA1: addr = {addr_h,alu_out};
        JSR0,PH1,RTS0,RTI0,BRK0: addr = {STACKPAGE,reg_val};
        BRK1,BRK2,JSR1,PL1,RTS1,RTS2,RTI1,RTI2,RTI3: addr = {STACKPAGE,alu_out};
        indX1,indX2,indY1,zpX1: addr = {ZEROPAGE, alu_out};
        indY0,zp0: addr = {ZEROPAGE, din_mux};
        REG,READ,WRITE: addr = {addr_h,addr_l};
        default: addr = pc;
    endcase
end
