`timescale 1ns/1ps

`define Itype   2'b00
`define Dtype   2'b01
`define CBtype  2'b10
`define Btype   2'b11

module SignExtender_tb;
    //regs controlled by tb and wire are outputs from the test
    // Testbench signals
    reg [25:0] Instruction;
    reg [1:0]  SignOp;
    wire [63:0] SignExOut;
    
    // Expected output for verification
    reg [63:0] expected;
    
    // Test counters
    integer i;
    integer errors;
    integer total_tests;
    
    // Instantiate the Sign Extender module (Unit Under Test)
    SignExtender uut (
        .SignExOut(SignExOut),
        .Instruction(Instruction),
        .SignOp(SignOp)
    );
    
    // Task to check results. like a function. prints error if the result doesnt match expected
    task check_result;
        input [63:0] expected_val;
        input [1:0] op_type;
        input [25:0] instr;
        begin
            if (SignExOut !== expected_val) begin
                $display("ERROR at time %0t: SignOp=%b, Instruction=%h", 
                         $time, op_type, instr);
                $display("  Expected: %h, Got: %h", expected_val, SignExOut);
                errors = errors + 1;
            end
            total_tests = total_tests + 1;
        end
    endtask
    
    // Function to compute expected I-Type output
    function [63:0] compute_itype;
        input [25:0] instr;
        begin
            // 12-bit immediate, sign extend from bit 11
            compute_itype = {{52{instr[11]}}, instr[11:0]};
        end
    endfunction
    
    // Function to compute expected D-Type output
    function [63:0] compute_dtype;
        input [25:0] instr;
        begin
            // 9-bit immediate, sign extend from bit 8
            compute_dtype = {{55{instr[8]}}, instr[8:0]};
        end
    endfunction
    
    // Function to compute expected CB-Type output
    function [63:0] compute_cbtype;
        input [25:0] instr;
        begin
            // 19-bit immediate, sign extend and shift left by 2
            compute_cbtype = {{43{instr[18]}}, instr[18:0], 2'b00};
        end
    endfunction
    
    // Function to compute expected B-Type output
    function [63:0] compute_btype;
        input [25:0] instr;
        begin
            // 26-bit immediate, sign extend and shift left by 2
            compute_btype = {{36{instr[25]}}, instr[25:0], 2'b00};
        end
    endfunction
    
    //begin testing
    initial begin
        // Initialize VCD dump
        $dumpfile("sign_extender.vcd");
        $dumpvars(0, SignExtender_tb);
        
        // Initialize counters
        errors = 0;
        total_tests = 0;
        
        $display("=== Sign Extender Testbench Starting ===");
        $display("Testing with 100 random values per instruction type");
        $display("");
        
        // Test I-Type instructions
        $display("Testing I-Type (SignOp = 00)...");
        SignOp = `Itype;
        
        // Test some specific corner cases first
        Instruction = 26'h0000000; #10;
        expected = compute_itype(Instruction);
        check_result(expected, SignOp, Instruction);
        
        Instruction = 26'h0000FFF; #10; // Max positive 12-bit
        expected = compute_itype(Instruction);
        check_result(expected, SignOp, Instruction);
        
        Instruction = 26'h0000800; #10; // Min negative 12-bit
        expected = compute_itype(Instruction);
        check_result(expected, SignOp, Instruction);
        
        // Random tests for I-Type
        for (i = 0; i < 100; i = i + 1) begin
            Instruction = $random & 26'h3FFFFFF;
            #10;
            expected = compute_itype(Instruction);
            check_result(expected, SignOp, Instruction);
        end
        
        // Test D-Type instructions
        $display("Testing D-Type (SignOp = 01)...");
        SignOp = `Dtype;
        
        // Corner cases
        Instruction = 26'h0000000; #10;
        expected = compute_dtype(Instruction);
        check_result(expected, SignOp, Instruction);
        
        Instruction = 26'h00001FF; #10; // Max positive 9-bit
        expected = compute_dtype(Instruction);
        check_result(expected, SignOp, Instruction);
        
        Instruction = 26'h0000100; #10; // Min negative 9-bit
        expected = compute_dtype(Instruction);
        check_result(expected, SignOp, Instruction);
        
        // Random tests for D-Type
        for (i = 0; i < 100; i = i + 1) begin
            Instruction = $random & 26'h3FFFFFF;
            #10;
            expected = compute_dtype(Instruction);
            check_result(expected, SignOp, Instruction);
        end
        
        // Test CB-Type instructions
        $display("Testing CB-Type (SignOp = 10)...");
        SignOp = `CBtype;
        
        // Corner cases
        Instruction = 26'h0000000; #10;
        expected = compute_cbtype(Instruction);
        check_result(expected, SignOp, Instruction);
        
        Instruction = 26'h003FFFF; #10; // Max positive 19-bit
        expected = compute_cbtype(Instruction);
        check_result(expected, SignOp, Instruction);
        
        Instruction = 26'h0040000; #10; // Min negative 19-bit
        expected = compute_cbtype(Instruction);
        check_result(expected, SignOp, Instruction);
        
        // Random tests for CB-Type
        for (i = 0; i < 100; i = i + 1) begin
            Instruction = $random & 26'h3FFFFFF;
            #10;
            expected = compute_cbtype(Instruction);
            check_result(expected, SignOp, Instruction);
        end
        
        // Test B-Type instructions
        $display("Testing B-Type (SignOp = 11)...");
        SignOp = `Btype;
        
        // Corner cases
        Instruction = 26'h0000000; #10;
        expected = compute_btype(Instruction);
        check_result(expected, SignOp, Instruction);
        
        Instruction = 26'h1FFFFFF; #10; // Max positive 26-bit
        expected = compute_btype(Instruction);
        check_result(expected, SignOp, Instruction);
        
        Instruction = 26'h2000000; #10; // Min negative 26-bit
        expected = compute_btype(Instruction);
        check_result(expected, SignOp, Instruction);
        
        Instruction = 26'h3FFFFFF; #10; // All ones
        expected = compute_btype(Instruction);
        check_result(expected, SignOp, Instruction);
        
        // Random tests for B-Type
        for (i = 0; i < 100; i = i + 1) begin
            Instruction = $random & 26'h3FFFFFF;
            #10;
            expected = compute_btype(Instruction);
            check_result(expected, SignOp, Instruction);
        end
        
        // Final report
        $display("");
        $display("=== Test Results ===");
        $display("Total tests: %0d", total_tests);
        $display("Errors: %0d", errors);
        
        if (errors == 0) begin
            $display("*** ALL TESTS PASSED ***");
        end else begin
            $display("*** TESTS FAILED ***");
        end
        
        $display("");
        $finish;
    end

endmodule