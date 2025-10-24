// Sign Extender Module for ARMv8 Processor
// Supports I-Type, D-Type, CB-Type, B-Type, and MOVZ instructions

`define Itype   2'b00
`define Dtype   2'b01
`define CBtype  2'b10
`define Btype   2'b11

module SignExtender(
    output reg [63:0] SignExOut,
    input      [31:0] Instruction,  // Changed from [25:0] to [31:0]
    input      [1:0]  SignOp
);

    reg [1:0] hw;  // Hardware shift field for MOVZ
    reg [15:0] imm16;  // 16-bit immediate for MOVZ
    
    always @(*) begin
        case (SignOp)
            `Itype: begin
                // Check if this is MOVZ (opcode 110100101 in bits [31:23])
                if (Instruction[31:23] == 9'b110100101) begin
                    // MOVZ: Extract 16-bit immediate and hw field
                    imm16 = Instruction[20:5];   // 16-bit immediate
                    hw = Instruction[22:21];      // Shift amount selector
                    
                    // Zero-extend and shift based on hw field
                    case (hw)
                        2'b00: SignExOut = {48'b0, imm16};           // LSL 0
                        2'b01: SignExOut = {32'b0, imm16, 16'b0};    // LSL 16
                        2'b10: SignExOut = {16'b0, imm16, 32'b0};    // LSL 32
                        2'b11: SignExOut = {imm16, 48'b0};           // LSL 48
                        default: SignExOut = 64'b0;
                    endcase
                end
                else begin
                    // Regular I-Type: 12-bit immediate in bits [21:10]
                    SignExOut = {{52{Instruction[21]}}, Instruction[21:10]};
                end
            end
            
            `Dtype: begin
                // D-Type: 9-bit immediate in bits [20:12]
                SignExOut = {{55{Instruction[20]}}, Instruction[20:12]};
            end
            
            `CBtype: begin
                // CB-Type: 19-bit immediate in bits [23:5]
                SignExOut = {{43{Instruction[23]}}, Instruction[23:5], 2'b00};
            end
            
            `Btype: begin
                // B-Type: 26-bit immediate in bits [25:0]
                SignExOut = {{36{Instruction[25]}}, Instruction[25:0], 2'b00};
            end
            
            default: begin
                SignExOut = 64'b0;
            end
        endcase
    end

endmodule