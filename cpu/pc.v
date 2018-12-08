
// determine pc_mux and pc_inc
always @*
    case (state)
        DECODE:
            if ((~I & irq) | nmi_edge) begin
                pc_mux = {addr_h, addr_l};
                pc_inc = 0;
            end
            else begin
                pc_mux = pc;
                pc_inc = 1;
            end
        JMPa1,JMPi1,RTS3,RTI4: begin
            pc_mux = {din_mux, alu_out};
            pc_inc = 1;
        end
        JSR3: begin
            pc_mux = {din_mux, alu_out};
            pc_inc = 0;
        end
        abs0, absX0, FETCH, BRA0, BRK3: begin
            pc_mux = pc;
            pc_inc = 1;
        end
        BRA1: begin
            pc_mux = {addr_h, alu_out};
            pc_inc = carry_out ^ ~backwards;
        end
        BRA2: begin
            pc_mux = {alu_out, pc[7:0]};
            pc_inc = 1;
        end
        BRK2: begin
            pc_mux = res ? 16'hfffc : nmi_edge ? 16'hfffa : 16'hfffe;
            pc_inc = 0;
        end
        default: begin
            pc_mux = pc;
            pc_inc = 0;
        end
    endcase

// set new PC value
always @(posedge clock)
    if (ready) pc <= pc_mux + pc_inc;
 
