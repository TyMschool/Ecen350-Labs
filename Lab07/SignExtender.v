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
                // I-Type: 12-bit immediate in bits [21:10]
                SignExOut = {{52{Instruction[21]}}, Instruction[21:10]};
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