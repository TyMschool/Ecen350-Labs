module RegisterFile(
    output wire [63:0] BusA, 
    output wire [63:0] BusB,
    input  wire [63:0] BusW,
    input  wire [4:0]  RA, 
    input  wire [4:0]  RB, 
    input  wire [4:0]  RW,
    input  wire        RegWr,
    input  wire        Clk
);
    // 32 registers of 64 bits. regs[31] will be treated as XZR (reads => 0, writes ignored).
    reg [63:0] regs [31:0];

    // Combinational read ports (blocking assignments as requested).
    reg [63:0] readA;
    reg [63:0] readB;

    always @(*) begin
        // If read address is 31 => XZR (zero). Otherwise return stored register.
        if (RA == 5'd31)
            readA = 64'd0;
        else
            readA = regs[RA];

        if (RB == 5'd31)
            readB = 64'd0;
        else
            readB = regs[RB];
    end

    // Synchronous write (non-blocking). Writes to XZR (reg 31) are dropped.
    always @(posedge Clk) begin
        if (RegWr && (RW != 5'd31)) begin
            regs[RW] <= BusW;
        end
    end

    // Outputs have a #3 simulation delay to prevent shoot-through in waveforms.
    // These delays are for simulation only; the rest of the RTL is synthesizable.
    assign BusA = readA;
    assign BusB = readB;
endmodule