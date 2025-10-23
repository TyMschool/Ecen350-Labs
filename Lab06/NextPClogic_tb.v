// Self-Checking Testbench for NextPC Logic Module
// Tests all combinations of control inputs with randomized data

`timescale 1ns/1ps

module NextPClogic_tb;

    // Testbench signals
    reg [63:0] CurrentPC;
    reg [63:0] SignExtImm64;
    reg Branch;
    reg ALUZero;
    reg Uncondbranch;
    wire [63:0] NextPC;
    
    // Expected output for verification
    reg [63:0] expected_NextPC;
    
    // Test counters
    integer i;
    integer errors;
    integer total_tests;
    
    // Instantiate the NextPC logic module
    NextPClogic uut (
        .NextPC(NextPC),
        .CurrentPC(CurrentPC),
        .SignExtImm64(SignExtImm64),
        .Branch(Branch),
        .ALUZero(ALUZero),
        .Uncondbranch(Uncondbranch)
    );
    
    // Task to check results
    task check_result;
        input [63:0] exp_NextPC;
        input [63:0] curr_pc;
        input [63:0] imm;
        input br;
        input zero;
        input uncond;
        begin
            #1; // Small delay for signals to settle
            if (NextPC !== exp_NextPC) begin
                $display("ERROR at time %0t:", $time);
                $display("  Inputs: CurrentPC=%h, SignExtImm64=%h", curr_pc, imm);
                $display("          Branch=%b, ALUZero=%b, Uncondbranch=%b", br, zero, uncond);
                $display("  Expected NextPC: %h", exp_NextPC);
                $display("  Got NextPC:      %h", NextPC);
                errors = errors + 1;
            end
            total_tests = total_tests + 1;
        end
    endtask
    
    // Function to compute expected NextPC
    function [63:0] compute_expected;
        input [63:0] curr_pc;
        input [63:0] imm;
        input br;
        input zero;
        input uncond;
        begin
            if (uncond) begin
                compute_expected = curr_pc + imm;
            end
            else if (br && zero) begin
                compute_expected = curr_pc + imm;
            end
            else begin
                compute_expected = curr_pc + 4;
            end
        end
    endfunction
    
    // Task to test a specific control combination
    task test_control_combination;
        input br;
        input zero;
        input uncond;
        begin
            $display("Testing Branch=%b, ALUZero=%b, Uncondbranch=%b", br, zero, uncond);
            
            Branch = br;
            ALUZero = zero;
            Uncondbranch = uncond;
            
            // Perform 10 random tests for this control combination
            for (i = 0; i < 10; i = i + 1) begin
                // Generate random CurrentPC (aligned to 4-byte boundary for realism)
                CurrentPC = {$random, $random} & 64'hFFFFFFFFFFFFFFFC;
                
                // Generate random SignExtImm64
                SignExtImm64 = {$random, $random};
                
                // Compute expected result
                expected_NextPC = compute_expected(CurrentPC, SignExtImm64, Branch, ALUZero, Uncondbranch);
                
                #10;
                check_result(expected_NextPC, CurrentPC, SignExtImm64, Branch, ALUZero, Uncondbranch);
            end
        end
    endtask
    
    initial begin
        // Initialize VCD dump
        $dumpfile("nextpc.vcd");
        $dumpvars(0, NextPClogic_tb);
        
        // Initialize counters
        errors = 0;
        total_tests = 0;
        
        $display("=== NextPC Logic Testbench Starting ===");
        $display("Testing all 8 combinations of control inputs");
        $display("Each combination tested with 10 random data inputs");
        $display("");
        
        // Test all 8 combinations of the three control inputs
        // Branch=0, ALUZero=0, Uncondbranch=0 -> NextPC = CurrentPC + 4
        test_control_combination(0, 0, 0);
        
        // Branch=0, ALUZero=0, Uncondbranch=1 -> NextPC = CurrentPC + SignExtImm64
        test_control_combination(0, 0, 1);
        
        // Branch=0, ALUZero=1, Uncondbranch=0 -> NextPC = CurrentPC + 4
        test_control_combination(0, 1, 0);
        
        // Branch=0, ALUZero=1, Uncondbranch=1 -> NextPC = CurrentPC + SignExtImm64
        test_control_combination(0, 1, 1);
        
        // Branch=1, ALUZero=0, Uncondbranch=0 -> NextPC = CurrentPC + 4
        test_control_combination(1, 0, 0);
        
        // Branch=1, ALUZero=0, Uncondbranch=1 -> NextPC = CurrentPC + SignExtImm64
        test_control_combination(1, 0, 1);
        
        // Branch=1, ALUZero=1, Uncondbranch=0 -> NextPC = CurrentPC + SignExtImm64
        test_control_combination(1, 1, 0);
        
        // Branch=1, ALUZero=1, Uncondbranch=1 -> NextPC = CurrentPC + SignExtImm64
        test_control_combination(1, 1, 1);
        
        // Additional specific test cases
        $display("");
        $display("Testing specific corner cases...");
        
        // Test 1: Simple sequential execution
        CurrentPC = 64'h0000000000001000;
        SignExtImm64 = 64'h0000000000000100;
        Branch = 0;
        ALUZero = 0;
        Uncondbranch = 0;
        expected_NextPC = CurrentPC + 4;
        #10;
        check_result(expected_NextPC, CurrentPC, SignExtImm64, Branch, ALUZero, Uncondbranch);
        
        // Test 2: Unconditional branch forward
        CurrentPC = 64'h0000000000001000;
        SignExtImm64 = 64'h0000000000000100;
        Branch = 0;
        ALUZero = 0;
        Uncondbranch = 1;
        expected_NextPC = CurrentPC + SignExtImm64;
        #10;
        check_result(expected_NextPC, CurrentPC, SignExtImm64, Branch, ALUZero, Uncondbranch);
        
        // Test 3: Unconditional branch backward (negative offset)
        CurrentPC = 64'h0000000000001000;
        SignExtImm64 = 64'hFFFFFFFFFFFFFF00; // Negative offset
        Branch = 0;
        ALUZero = 0;
        Uncondbranch = 1;
        expected_NextPC = CurrentPC + SignExtImm64;
        #10;
        check_result(expected_NextPC, CurrentPC, SignExtImm64, Branch, ALUZero, Uncondbranch);
        
        // Test 4: Conditional branch taken (CBZ with zero register)
        CurrentPC = 64'h0000000000002000;
        SignExtImm64 = 64'h0000000000000080;
        Branch = 1;
        ALUZero = 1;
        Uncondbranch = 0;
        expected_NextPC = CurrentPC + SignExtImm64;
        #10;
        check_result(expected_NextPC, CurrentPC, SignExtImm64, Branch, ALUZero, Uncondbranch);
        
        // Test 5: Conditional branch not taken (CBZ with non-zero register)
        CurrentPC = 64'h0000000000002000;
        SignExtImm64 = 64'h0000000000000080;
        Branch = 1;
        ALUZero = 0;
        Uncondbranch = 0;
        expected_NextPC = CurrentPC + 4;
        #10;
        check_result(expected_NextPC, CurrentPC, SignExtImm64, Branch, ALUZero, Uncondbranch);
        
        // Test 6: Unconditional branch takes priority over conditional
        CurrentPC = 64'h0000000000003000;
        SignExtImm64 = 64'h0000000000000200;
        Branch = 1;
        ALUZero = 1;
        Uncondbranch = 1;
        expected_NextPC = CurrentPC + SignExtImm64;
        #10;
        check_result(expected_NextPC, CurrentPC, SignExtImm64, Branch, ALUZero, Uncondbranch);
        
        // Test 7: PC at zero
        CurrentPC = 64'h0000000000000000;
        SignExtImm64 = 64'h0000000000000010;
        Branch = 0;
        ALUZero = 0;
        Uncondbranch = 0;
        expected_NextPC = CurrentPC + 4;
        #10;
        check_result(expected_NextPC, CurrentPC, SignExtImm64, Branch, ALUZero, Uncondbranch);
        
        // Test 8: Large PC value
        CurrentPC = 64'hFFFFFFFFFFFFF000;
        SignExtImm64 = 64'h0000000000001000;
        Branch = 0;
        ALUZero = 0;
        Uncondbranch = 1;
        expected_NextPC = CurrentPC + SignExtImm64;
        #10;
        check_result(expected_NextPC, CurrentPC, SignExtImm64, Branch, ALUZero, Uncondbranch);
        
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