`timescale 1ns / 1ps

module SingleCycleProc(
		   input	     reset, //Active High
		   input [63:0]	     startpc,
		   output reg [63:0] currentpc,
		   output [63:0]     MemtoRegOut, // this should be
						   // attached to the
						   // output of the
						   // MemtoReg Mux
		   input	     CLK
		   );

   // Next PC connections
   wire [63:0] 			     nextpc;       // The next PC, to be updated on clock cycle

   // Instruction Memory connections
   wire [31:0] 			     instruction;  // The current instruction

   // Parts of instruction
   wire [4:0] 			     rd;            // The destination register
   wire [4:0] 			     rm;            // Operand 1
   wire [4:0] 			     rn;            // Operand 2
   wire [10:0] 			     opcode;

   // Control wires
   wire 			     Reg2Loc;
   wire 			     ALUSrc;
   wire 			     MemtoReg;
   wire 			     RegWrite;
   wire 			     MemRead;
   wire 			     MemWrite;
   wire 			     Branch;
   wire 			     Uncondbranch;
   wire [3:0] 			     ALUOp;
   wire [1:0] 			     SignOp;

   // Register file connections
   wire [63:0] 			     regoutA;     // Output A
   wire [63:0] 			     regoutB;     // Output B

   // ALU connections
   wire [63:0] 			     aluout;
   wire 			     zero;

   // Sign Extender connections
   wire [63:0] 			     extimm;

   // Data Memory connections
   wire [63:0] 			     dmemout;     // Data memory output

   // Additional mux wires
   wire [63:0] 			     aluinputB;   // Second ALU input (from mux)

   // PC update logic
   always @(posedge CLK)
     begin
        if (reset)
          currentpc <= startpc;
        else
          currentpc <= nextpc;
     end

   // Parts of instruction
   assign rd = instruction[4:0];
   assign rm = instruction[9:5];
   assign rn = Reg2Loc ? instruction[4:0] : instruction[20:16];
   assign opcode = instruction[31:21];

   InstructionMemory imem(
			  .Data(instruction),
			  .Address(currentpc)
			  );

   SC_Control control(
		   .Reg2Loc(Reg2Loc),
		   .ALUSrc(ALUSrc),
		   .MemtoReg(MemtoReg),
		   .RegWrite(RegWrite),
		   .MemRead(MemRead),
		   .MemWrite(MemWrite),
		   .Branch(Branch),
		   .Uncondbranch(Uncondbranch),
		   .ALUOp(ALUOp),
		   .SignOp(SignOp),
		   .opcode(opcode)
		   );

   /*
    * Connect the remaining datapath elements below.
    * Do not forget any additional multiplexers that may be required.
    */

   // Register File
   RegisterFile regfile(
			.BusA(regoutA),
			.BusB(regoutB),
			.BusW(MemtoRegOut),
			.RA(rm),
			.RB(rn),
			.RW(rd),
			.RegWr(RegWrite),
			.Clk(CLK)
			);

   // Sign Extender
   SignExtender signext(
			.SignExOut(extimm),
			.Instruction(instruction),
			.SignOp(SignOp)
			);

   // ALU Input B Mux (selects between register or immediate)
   assign aluinputB = ALUSrc ? extimm : regoutB;

   // ALU
   ALU alu(
	   .BusW(aluout),
	   .BusA(regoutA),
	   .BusB(aluinputB),
	   .ALUCtrl(ALUOp),
	   .Zero(zero)
	   );

   // Data Memory
   DataMemory dmem(
		   .ReadData(dmemout),
		   .Address(aluout),
		   .WriteData(regoutB),
		   .MemoryRead(MemRead),
		   .MemoryWrite(MemWrite),
		   .Clock(CLK)
		   );

   // MemtoReg Mux (selects between ALU result or memory data)
   assign MemtoRegOut = MemtoReg ? dmemout : aluout;

   // Next PC Logic
   NextPClogic pclogic(
		       .NextPC(nextpc),
		       .CurrentPC(currentpc),
		       .SignExtImm64(extimm),
		       .Branch(Branch),
		       .ALUZero(zero),
		       .Uncondbranch(Uncondbranch)
		       );

endmodule