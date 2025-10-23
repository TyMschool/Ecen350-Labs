// 64-bit Arithmetic Logic Unit (ALU) for ARMv8 Processor
// Supports AND, OR, ADD, SUB, and PassB operations

`define AND   4'b0000
`define OR    4'b0001
`define ADD   4'b0010
`define SUB   4'b0110
`define PassB 4'b0111

module ALU(
    output reg [63:0] BusW,
    input      [63:0] BusA,
    input      [63:0] BusB,
    input      [3:0]  ALUCtrl,
    output            Zero
);

    // Zero flag is set when BusW is all zeros
    assign Zero = (BusW == 64'b0);

    always @(*) begin
        case (ALUCtrl)
            `AND: begin
                // Bitwise AND operation
                BusW = BusA & BusB;
            end
            
            `OR: begin
                // Bitwise OR operation
                BusW = BusA | BusB;
            end
            
            `ADD: begin
                // Addition operation
                BusW = BusA + BusB;
            end
            
            `SUB: begin
                // Subtraction operation
                BusW = BusA - BusB;
            end
            
            `PassB: begin
                // Pass input B (used by CBZ)
                BusW = BusB;
            end
            
            default: begin
                // Default case to avoid latches. should never execute
                BusW = 64'b0;
            end
        endcase
    end

endmodule