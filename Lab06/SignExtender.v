// Sign Extender Module for ARMv8 Processor
// Supports I-Type, D-Type, CB-Type, and B-Type instructions

`define Itype   2'b00
`define Dtype   2'b01
`define CBtype  2'b10
`define Btype   2'b11

module SignExtender(
    output reg [63:0] SignExOut,
    input      [25:0] Instruction,
    input      [1:0]  SignOp
);

    always @(*) begin
        case (SignOp)
            `Itype: begin
                // I-Type: 12-bit immediate (bits [11:0])
                // Sign extend from bit 11
                SignExOut = {{52{Instruction[11]}}, Instruction[11:0]};
            end
            
            `Dtype: begin
                // D-Type: 9-bit immediate (bits [8:0])
                // Sign extend from bit 8
                SignExOut = {{55{Instruction[8]}}, Instruction[8:0]};
            end
            
            `CBtype: begin
                // CB-Type: 19-bit immediate (bits [18:0])
                // Sign extend and shift left by 2 bits to mainttain 4 byte alignments
                SignExOut = {{43{Instruction[18]}}, Instruction[18:0], 2'b00};
            end
            
            `Btype: begin
                // B-Type: 26-bit immediate (bits [25:0])
                // Sign extend and shift left by 2 bits to mainttain 4 byte alignments
                SignExOut = {{36{Instruction[25]}}, Instruction[25:0], 2'b00};
            end
            
            default: begin
                SignExOut = 64'b0;
            end
        endcase
    end

endmodule