`timescale 1ns/1ps


module SC_Control_tb();


    // Testbench signals
    reg [10:0] opcode;
    wire Reg2Loc, ALUSrc, MemtoReg, RegWrite, MemRead, MemWrite, Branch, Uncondbranch;
    wire [3:0] ALUOp;
    wire [1:0] SignOp;
    
    // Test tracking
    integer test_num;
    integer errors;
    integer i;
    reg [10:0] random_opcode;
    
    // Instantiate the control unit
    SC_Control uut (
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
    
    // Task to check outputs against expected values
    task check_outputs;
        input [10:0] test_opcode;
        input exp_Reg2Loc, exp_ALUSrc, exp_MemtoReg, exp_RegWrite;
        input exp_MemRead, exp_MemWrite, exp_Branch, exp_Uncondbranch;
        input [3:0] exp_ALUOp;
        input [1:0] exp_SignOp;
        input [200*8:1] test_name;
        begin
            #1; // Wait for combinational logic to settle
            if (Reg2Loc !== exp_Reg2Loc || ALUSrc !== exp_ALUSrc || 
                MemtoReg !== exp_MemtoReg || RegWrite !== exp_RegWrite ||
                MemRead !== exp_MemRead || MemWrite !== exp_MemWrite ||
                Branch !== exp_Branch || Uncondbranch !== exp_Uncondbranch ||
                ALUOp !== exp_ALUOp || SignOp !== exp_SignOp) begin
                
                $display("ERROR: Test %0d - %s (opcode=11'b%b)", test_num, test_name, test_opcode);
                $display("  Expected: Reg2Loc=%b ALUSrc=%b MemtoReg=%b RegWrite=%b MemRead=%b MemWrite=%b Branch=%b Uncondbranch=%b ALUOp=%b SignOp=%b",
                         exp_Reg2Loc, exp_ALUSrc, exp_MemtoReg, exp_RegWrite, exp_MemRead, 
                         exp_MemWrite, exp_Branch, exp_Uncondbranch, exp_ALUOp, exp_SignOp);
                $display("  Got:      Reg2Loc=%b ALUSrc=%b MemtoReg=%b RegWrite=%b MemRead=%b MemWrite=%b Branch=%b Uncondbranch=%b ALUOp=%b SignOp=%b",
                         Reg2Loc, ALUSrc, MemtoReg, RegWrite, MemRead, 
                         MemWrite, Branch, Uncondbranch, ALUOp, SignOp);
                errors = errors + 1;
            end else begin
                $display("PASS: Test %0d - %s", test_num, test_name);
            end
            test_num = test_num + 1;
        end
    endtask
    
    initial begin
        // Initialize
        test_num = 0;
        errors = 0;
        opcode = 11'b0;
        
        // Create VCD dump file
        $dumpfile("sc_control_tb.vcd");
        $dumpvars(0, SC_Control_tb);
        
        $display("Starting SC_Control testbench...");
        $display("=====================================");
        
        // Test R-type instructions
        $display("\nTesting R-type instructions:");
        
        // ADD Register
        opcode = 11'b10001011000;
        check_outputs(opcode, 0, 0, 0, 1, 0, 0, 0, 0, 4'b0010, 2'bxx, "ADD Register");
        
        // SUB Register
        opcode = 11'b11001011000;
        check_outputs(opcode, 0, 0, 0, 1, 0, 0, 0, 0, 4'b0110, 2'bxx, "SUB Register");
        
        // AND Register
        opcode = 11'b10001010000;
        check_outputs(opcode, 0, 0, 0, 1, 0, 0, 0, 0, 4'b0000, 2'bxx, "AND Register");
        
        // ORR Register
        opcode = 11'b10101010000;
        check_outputs(opcode, 0, 0, 0, 1, 0, 0, 0, 0, 4'b0001, 2'bxx, "ORR Register");
        
        // Test I-type instructions with don't care bits
        $display("\nTesting I-type instructions (ADDIMM):");
        
        // ADDIMM - test both possibilities for bit 0 (don't care)
        for (i = 0; i < 2; i = i + 1) begin
            opcode = 11'b10010001000 | i;
            check_outputs(opcode, 1'bx, 1, 0, 1, 0, 0, 0, 0, 4'b0010, 2'b00, "ADD Immediate");
        end

        // SUBIMM - test both possibilities for bit 0 (don't care)
        for (i = 0; i < 2; i = i + 1) begin
            opcode = 11'b11010001000 | i;
            check_outputs(opcode, 1'bx, 1, 0, 1, 0, 0, 0, 0, 4'b0110, 2'b00, "SUB Immediate");
        end

        // MOVZ - test all 4 possibilities for bits [1:0] (don't cares)
        for (i = 0; i < 4; i = i + 1) begin
            opcode = 11'b11010010100 | i;
            check_outputs(opcode, 1'bx, 1, 0, 1, 0, 0, 0, 0, 4'b0111, 2'b00, "MOVZ");
        end

        // B (Unconditional) - test all 32 possibilities for bits [4:0] (don't cares)
        for (i = 0; i < 32; i = i + 1) begin
            opcode = 11'b00010100000 | i;
            check_outputs(opcode, 1'bx, 1'bx, 1'bx, 0, 0, 0, 0, 1, 4'bxxxx, 2'b11, "B (Unconditional)");
        end

        // CBZ - test all 8 possibilities for bits [2:0] (don't cares)
        for (i = 0; i < 8; i = i + 1) begin
            opcode = 11'b10110100000 | i;
            check_outputs(opcode, 1, 0, 1'bx, 0, 0, 0, 1, 0, 4'b0111, 2'b10, "CBZ");
        end

        // LDUR
        opcode = 11'b11111000010;
        check_outputs(opcode, 1'bx, 1, 1, 1, 1, 0, 0, 0, 4'b0010, 2'b01, "LDUR");

        // STUR
        opcode = 11'b11111000000;
        check_outputs(opcode, 1, 1, 1'bx, 0, 0, 1, 0, 0, 4'b0010, 2'b01, "STUR");
        
        $display("\nTesting undefined opcodes (should output all zeros):");
        
        // Test 10 random undefined opcodes
        // Using specific random values that don't match any defined opcodes
        random_opcode = 11'b00000000000; opcode = random_opcode;
        check_outputs(opcode, 0, 0, 0, 0, 0, 0, 0, 0, 4'b0000, 2'b00, "Undefined opcode 1");
        
        random_opcode = 11'b11111111111; opcode = random_opcode;
        check_outputs(opcode, 0, 0, 0, 0, 0, 0, 0, 0, 4'b0000, 2'b00, "Undefined opcode 2");
        
        random_opcode = 11'b01010101010; opcode = random_opcode;
        check_outputs(opcode, 0, 0, 0, 0, 0, 0, 0, 0, 4'b0000, 2'b00, "Undefined opcode 3");
        
        random_opcode = 11'b10101010101; opcode = random_opcode;
        check_outputs(opcode, 0, 0, 0, 0, 0, 0, 0, 0, 4'b0000, 2'b00, "Undefined opcode 4");
        
        random_opcode = 11'b00110011001; opcode = random_opcode;
        check_outputs(opcode, 0, 0, 0, 0, 0, 0, 0, 0, 4'b0000, 2'b00, "Undefined opcode 5");
        
        random_opcode = 11'b11001100110; opcode = random_opcode;
        check_outputs(opcode, 0, 0, 0, 0, 0, 0, 0, 0, 4'b0000, 2'b00, "Undefined opcode 6");
        
        random_opcode = 11'b00011100011; opcode = random_opcode;
        check_outputs(opcode, 0, 0, 0, 0, 0, 0, 0, 0, 4'b0000, 2'b00, "Undefined opcode 7");
        
        random_opcode = 11'b11100011100; opcode = random_opcode;
        check_outputs(opcode, 0, 0, 0, 0, 0, 0, 0, 0, 4'b0000, 2'b00, "Undefined opcode 8");
        
        random_opcode = 11'b01111110000; opcode = random_opcode;
        check_outputs(opcode, 0, 0, 0, 0, 0, 0, 0, 0, 4'b0000, 2'b00, "Undefined opcode 9");
        
        random_opcode = 11'b10000001111; opcode = random_opcode;
        check_outputs(opcode, 0, 0, 0, 0, 0, 0, 0, 0, 4'b0000, 2'b00, "Undefined opcode 10");
        
        // Display summary
        $display("\n=====================================");
        $display("Test Summary:");
        $display("  Total tests: %0d", test_num);
        $display("  Passed: %0d", test_num - errors);
        $display("  Failed: %0d", errors);
        
        if (errors == 0) begin
            $display("\nALL TESTS PASSED!");
        end else begin
            $display("\nSOME TESTS FAILED!");
        end
        
        $display("=====================================");
        
        // Finish simulation
        #10;
        $finish;
    end


endmodule