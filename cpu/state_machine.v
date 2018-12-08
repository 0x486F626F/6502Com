always @(posedge clock or posedge reset)
    if (reset) begin
        state <= BRK0;
    end else if (ready) begin 
        case(state) 
            DECODE:
            casex (ir)
                8'b00000000: state <= BRK0;     // (BRK impl)
                8'b00100000: state <= JSR0;     // (JSR abs)
                8'b00101100: state <= abs0;     // (BIT abs)
                8'b01000000: state <= RTI0;     // (RTI impl)
                8'b01001100: state <= JMPa0;    // (JMP abs)
                8'b01100000: state <= RTS0;     // (RTS impl)
                8'b01101100: state <= JMPi0;    // (JMP ind)

                8'b0x001000: state <= PH0;      // (PHP/PHA impl)
                8'b0x101000: state <= PL0;      // (PLP/PLA impl)
                8'b0xx11000: state <= REG;      // (CLC/SEC/CLI/SEI impl)
                8'b1xx000x0: state <= FETCH;    // 2-cycle immediate
                8'b1xx01100: state <= abs0;     // (STY/LDY/CPY/CPX abs)
                8'b1xxx1000: state <= REG;      // (DEY/TYA/TAY/CLV/INY/CLD/INX/SED impl)
                8'bxxx00001: state <= indX0;    // ind X
                8'bxxx001xx: state <= zp0;      // zeropage
                8'bxxx01001: state <= FETCH;    // 2-cycle immediate
                8'bxxx01101: state <= abs0;
                8'bxxx01110: state <= abs0;
                8'bxxx10000: state <= BRA0;     // branch
                8'bxxx10001: state <= indY0;    // ind Y
                8'bxxx101xx: state <= zpX0;     // zeropage 0
                8'bxxx11001: state <= absX0;
                8'bxxx111xx: state <= absX0;
                8'bxxxx1010: state <= REG;
                default: state <= BRK0;
            endcase
            REG:    state <= DECODE;
            READ:   state <= WRITE;
            WRITE:  state <= FETCH;
            FETCH:  state <= DECODE;
            abs0:   state <= abs1;
            abs1:   state <= write_back ? READ : FETCH;
            absX0:  state <= absX1;
            absX1:  state <= (carry_out | store| write_back) ? absX2 : FETCH;
            absX2:  state <= write_back ? READ : FETCH;
            indX0:  state <= indX1;
            indX1:  state <= indX2;
            indX2:  state <= indX3;
            indX3:  state <= FETCH;
            indY0:  state <= indY1;
            indY1:  state <= indY2;
            indY2:  state <= (carry_out |store) ? indY3 :FETCH;
            indY3:  state <= FETCH;
            zp0:    state <= write_back ? READ : FETCH;
            zpX0:   state <= zpX1;
            zpX1:   state <= write_back ? READ : FETCH;
            BRA0:   state <= cond_true ? BRA1 : DECODE;
            BRA1:   state <= (carry_out ^ backwards) ? BRA2 : DECODE;
            BRA2:   state <= DECODE;
            BRK0:   state <= BRK1;
            BRK1:   state <= BRK2;
            BRK2:   state <= BRK3;
            BRK3:   state <= JMPa0;
            JSR0:   state <= JSR1;
            JSR1:   state <= JSR2;
            JSR2:   state <= JSR3;
            JSR3:   state <= FETCH;
            JMPa0:  state <= JMPa1;
            JMPa1:  state <= DECODE;
            JMPi0:  state <= JMPi1;
            JMPi1:  state <= JMPa0;
            RTI0:   state <= RTI1;
            RTI1:   state <= RTI2;
            RTI2:   state <= RTI3;
            RTI3:   state <= RTI4;
            RTI4:   state <= DECODE;
            RTS0:   state <= RTS1;
            RTS1:   state <= RTS2;
            RTS2:   state <= RTS3;
            RTS3:   state <= FETCH;
            PH0:    state <= PH1;
            PH1:    state <= DECODE;
            PL0:    state <= PL1;
            PL1:    state <= PL2;
            PL2:    state <= DECODE;
            default: state <= BRK0;
        endcase
    end
