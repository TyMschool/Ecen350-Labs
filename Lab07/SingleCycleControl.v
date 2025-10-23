`timescale 1ns / 1ps

`define OPCODE_ANDREG 11'b10001010000
`define OPCODE_ORRREG 11'b10101010000
`define OPCODE_ADDREG 11'b10001011000
`define OPCODE_SUBREG 11'b11001011000

`define OPCODE_ADDIMM 11'b1001000100?
`define OPCODE_SUBIMM 11'b1101000100?

`define OPCODE_MOVZ   11'b110100101??

`define OPCODE_B      11'b000101?????
`define OPCODE_CBZ    11'b10110100???

`define OPCODE_LDUR   11'b11111000010
`define OPCODE_STUR   11'b11111000000

module SC_Control(
               output reg       Reg2Loc,
               output reg       ALUSrc,
               output reg       MemtoReg,
               output reg       RegWrite,
               output reg       MemRead,
               output reg       MemWrite,
               output reg       Branch,
               output reg       Uncondbranch,
               output reg [3:0] ALUOp,
               output reg [1:0] SignOp,
               input [10:0]     opcode
               );

    always @(opcode) begin
        // Default values (all zeros for undefined opcodes)
        Reg2Loc = 1'b0;
        ALUSrc = 1'b0;
        MemtoReg = 1'b0;
        RegWrite = 1'b0;
        MemRead = 1'b0;
        MemWrite = 1'b0;
        Branch = 1'b0;
        Uncondbranch = 1'b0;
        ALUOp = 4'b0000;
        SignOp = 2'b00;
        
        casez(opcode)
            // R-type instructions (register-register operations)
            `OPCODE_ADDREG: begin
                Reg2Loc = 1'b0;
                ALUSrc = 1'b0;
                MemtoReg = 1'b0;
                RegWrite = 1'b1;
                MemRead = 1'b0;
                MemWrite = 1'b0;
                Branch = 1'b0;
                Uncondbranch = 1'b0;
                ALUOp = 4'b0010;
                SignOp = 2'bXX;
            end
            
            `OPCODE_SUBREG: begin
                Reg2Loc = 1'b0;
                ALUSrc = 1'b0;
                MemtoReg = 1'b0;
                RegWrite = 1'b1;
                MemRead = 1'b0;
                MemWrite = 1'b0;
                Branch = 1'b0;
                Uncondbranch = 1'b0;
                ALUOp = 4'b0110;
                SignOp = 2'bXX;
            end
            
            `OPCODE_ANDREG: begin
                Reg2Loc = 1'b0;
                ALUSrc = 1'b0;
                MemtoReg = 1'b0;
                RegWrite = 1'b1;
                MemRead = 1'b0;
                MemWrite = 1'b0;
                Branch = 1'b0;
                Uncondbranch = 1'b0;
                ALUOp = 4'b0000;
                SignOp = 2'bXX;
            end
            
            `OPCODE_ORRREG: begin
                Reg2Loc = 1'b0;
                ALUSrc = 1'b0;
                MemtoReg = 1'b0;
                RegWrite = 1'b1;
                MemRead = 1'b0;
                MemWrite = 1'b0;
                Branch = 1'b0;
                Uncondbranch = 1'b0;
                ALUOp = 4'b0001;
                SignOp = 2'bXX;
            end
            
            `OPCODE_ADDIMM: begin
                Reg2Loc = 1'bX;
                ALUSrc = 1'b1;
                MemtoReg = 1'b0;
                RegWrite = 1'b1;
                MemRead = 1'b0;
                MemWrite = 1'b0;
                Branch = 1'b0;
                Uncondbranch = 1'b0;
                ALUOp = 4'b0010;
                SignOp = 2'b00;
            end
            
            `OPCODE_SUBIMM: begin
                Reg2Loc = 1'bX;
                ALUSrc = 1'b1;
                MemtoReg = 1'b0;
                RegWrite = 1'b1;
                MemRead = 1'b0;
                MemWrite = 1'b0;
                Branch = 1'b0;
                Uncondbranch = 1'b0;
                ALUOp = 4'b0110;
                SignOp = 2'b00;
            end
            
            `OPCODE_MOVZ: begin
                Reg2Loc = 1'bX;
                ALUSrc = 1'b1;
                MemtoReg = 1'b0;
                RegWrite = 1'b1;
                MemRead = 1'b0;
                MemWrite = 1'b0;
                Branch = 1'b0;
                Uncondbranch = 1'b0;
                ALUOp = 4'b0111;
                SignOp = 2'b00;  //or 10?
            end
            
            `OPCODE_LDUR: begin
                Reg2Loc = 1'bX;
                ALUSrc = 1'b1;
                MemtoReg = 1'b1;
                RegWrite = 1'b1;
                MemRead = 1'b1;
                MemWrite = 1'b0;
                Branch = 1'b0;
                Uncondbranch = 1'b0;
                ALUOp = 4'b0010;
                SignOp = 2'b01;
            end
            
            `OPCODE_STUR: begin
                Reg2Loc = 1'b1;
                ALUSrc = 1'b1;
                MemtoReg = 1'bX;
                RegWrite = 1'b0;
                MemRead = 1'b0;
                MemWrite = 1'b1;
                Branch = 1'b0;
                Uncondbranch = 1'b0;
                ALUOp = 4'b0010;
                SignOp = 2'b01;
            end
            
            `OPCODE_B: begin
                Reg2Loc = 1'bX;
                ALUSrc = 1'bX;
                MemtoReg = 1'bX;
                RegWrite = 1'b0;
                MemRead = 1'b0;
                MemWrite = 1'b0;
                Branch = 1'b0;
                Uncondbranch = 1'b1;
                ALUOp = 4'bXXXX;
                SignOp = 2'b11;
            end
            
            `OPCODE_CBZ: begin
                Reg2Loc = 1'b1;
                ALUSrc = 1'b0;
                MemtoReg = 1'bX;
                RegWrite = 1'b0;
                MemRead = 1'b0;
                MemWrite = 1'b0;
                Branch = 1'b1;
                Uncondbranch = 1'b0;
                ALUOp = 4'b0111;
                SignOp = 2'b10;
            end
            
            default: begin
                Reg2Loc = 1'b0;
                ALUSrc = 1'b0;
                MemtoReg = 1'b0;
                RegWrite = 1'b0;
                MemRead = 1'b0;
                MemWrite = 1'b0;
                Branch = 1'b0;
                Uncondbranch = 1'b0;
                ALUOp = 4'b0000;
                SignOp = 2'b00;
            end
        endcase
    end

endmodule