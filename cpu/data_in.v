always @(posedge clock) begin 
    if (ready) din_hold <= din;

    // ir_hold_valid
    if (reset) ir_hold_valid <= 0;
    else if (ready) begin
        if (state == PL0 || state == PH0) begin
            ir_hold <= din_mux;
            ir_hold_valid <= 1;
        end else if (state == DECODE) ir_hold_valid <= 0;
    end
end

assign din_mux = ready ? din : din_hold;

assign ir = ((~I & irq) | nmi_edge) ? 8'h00:
    ir_hold_valid ? ir_hold : din_mux;
