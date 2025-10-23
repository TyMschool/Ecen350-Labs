module mux2to1_8 (
    input  wire [7:0] in0,   // Input 0
    input  wire [7:0] in1,   // Input 1
    input  wire       sel,   // Select signal
    output reg  [7:0] out    // Output
);

    always @(*) begin
        if (sel == 1'b0)
            out = in0;
        else
            out = in1;
    end

endmodule
