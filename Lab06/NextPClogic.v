// NextPC Logic Module for ARMv8 Processor
// Determines the next Program Counter value based on branch conditions

module NextPClogic(
    output reg [63:0] NextPC,
    input  [63:0] CurrentPC,
    input  [63:0] SignExtImm64,
    input         Branch,
    input         ALUZero,
    input         Uncondbranch
);

    always @(*) begin
        // Unconditional branch takes highest priority
        if (Uncondbranch) begin
            // For unconditional branch (B instruction)
            // NextPC = CurrentPC + SignExtImm64
            NextPC = CurrentPC + SignExtImm64;
        end
        // Conditional branch when both Branch and ALUZero are true
        else if (Branch && ALUZero) begin
            // For conditional branch taken (CBZ instruction when register is zero)
            // NextPC = CurrentPC + SignExtImm64
            NextPC = CurrentPC + SignExtImm64;
        end
        // Otherwise, proceed to next sequential instruction
        else begin
            // No branch: NextPC = CurrentPC + 4
            NextPC = CurrentPC + 4;
        end
    end
endmodule