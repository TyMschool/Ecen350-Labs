// Self-Checking Testbench for ALU Module
// Tests all ALU operations with randomized inputs and corner cases

`timescale 1ns/1ps

`define AND   4'b0000
`define OR    4'b0001
`define ADD   4'b0010
`define SUB   4'b0110
`define PassB 4'b0111

module ALU_tb;

    // Testbench signals
    reg [63:0] BusA;
    reg [63:0] BusB;
    reg [3:0]  ALUCtrl;
    wire [63:0] BusW;
    wire Zero;
    
    // Expected outputs for verification
    reg [63:0] expected_BusW;
    reg expected_Zero;
    
    // Test counters
    integer i;
    integer errors;
    integer total_tests;
    
    // Instantiate the ALU module
    ALU uut (
        .BusW(BusW),
        .BusA(BusA),
        .BusB(BusB),
        .ALUCtrl(ALUCtrl),
        .Zero(Zero)
    );
    
    // Task to check results
    task check_result;
        input [63:0] exp_BusW;
        input exp_Zero;
        input [3:0] ctrl;
        input [63:0] a;
        input [63:0] b;
        begin
            #1; // Small delay for signals to settle
            if (BusW !== exp_BusW || Zero !== exp_Zero) begin
                $display("ERROR at time %0t: ALUCtrl=%b, BusA=%h, BusB=%h", 
                         $time, ctrl, a, b);
                $display("  Expected: BusW=%h, Zero=%b", exp_BusW, exp_Zero);
                $display("  Got:      BusW=%h, Zero=%b", BusW, Zero);
                errors = errors + 1;
            end
            total_tests = total_tests + 1;
        end
    endtask
    
    // Task to test a specific operation
    task test_operation;
        input [3:0] op;
        input [127:0] op_name;
        begin
            $display("Testing %0s operation (ALUCtrl = %b)...", op_name, op);
            ALUCtrl = op;
            
            // Test corner cases: all zeros and all ones combinations
            // Case 1: A=0, B=0
            BusA = 64'h0000000000000000;
            BusB = 64'h0000000000000000;
            case (op)
                `AND:   expected_BusW = BusA & BusB;
                `OR:    expected_BusW = BusA | BusB;
                `ADD:   expected_BusW = BusA + BusB;
                `SUB:   expected_BusW = BusA - BusB;
                `PassB: expected_BusW = BusB;
                default: expected_BusW = 64'b0;
            endcase
            expected_Zero = (expected_BusW == 64'b0);
            #10;
            check_result(expected_BusW, expected_Zero, op, BusA, BusB);
            
            // Case 2: A=0, B=all 1's
            BusA = 64'h0000000000000000;
            BusB = 64'hFFFFFFFFFFFFFFFF;
            case (op)
                `AND:   expected_BusW = BusA & BusB;
                `OR:    expected_BusW = BusA | BusB;
                `ADD:   expected_BusW = BusA + BusB;
                `SUB:   expected_BusW = BusA - BusB;
                `PassB: expected_BusW = BusB;
                default: expected_BusW = 64'b0;
            endcase
            expected_Zero = (expected_BusW == 64'b0);
            #10;
            check_result(expected_BusW, expected_Zero, op, BusA, BusB);
            
            // Case 3: A=all 1's, B=0
            BusA = 64'hFFFFFFFFFFFFFFFF;
            BusB = 64'h0000000000000000;
            case (op)
                `AND:   expected_BusW = BusA & BusB;
                `OR:    expected_BusW = BusA | BusB;
                `ADD:   expected_BusW = BusA + BusB;
                `SUB:   expected_BusW = BusA - BusB;
                `PassB: expected_BusW = BusB;
                default: expected_BusW = 64'b0;
            endcase
            expected_Zero = (expected_BusW == 64'b0);
            #10;
            check_result(expected_BusW, expected_Zero, op, BusA, BusB);
            
            // Case 4: A=all 1's, B=all 1's
            BusA = 64'hFFFFFFFFFFFFFFFF;
            BusB = 64'hFFFFFFFFFFFFFFFF;
            case (op)
                `AND:   expected_BusW = BusA & BusB;
                `OR:    expected_BusW = BusA | BusB;
                `ADD:   expected_BusW = BusA + BusB;
                `SUB:   expected_BusW = BusA - BusB;
                `PassB: expected_BusW = BusB;
                default: expected_BusW = 64'b0;
            endcase
            expected_Zero = (expected_BusW == 64'b0);
            #10;
            check_result(expected_BusW, expected_Zero, op, BusA, BusB);
            
            // Test at least one case that produces Zero=1
            case (op)
                `AND: begin
                    BusA = 64'hAAAAAAAAAAAAAAAA;
                    BusB = 64'h5555555555555555;
                end
                `OR: begin
                    BusA = 64'h0000000000000000;
                    BusB = 64'h0000000000000000;
                end
                `ADD: begin
                    BusA = 64'h0000000000000000;
                    BusB = 64'h0000000000000000;
                end
                `SUB: begin
                    BusA = 64'h1234567890ABCDEF;
                    BusB = 64'h1234567890ABCDEF;
                end
                `PassB: begin
                    BusB = 64'h0000000000000000;
                end
            endcase
            case (op)
                `AND:   expected_BusW = BusA & BusB;
                `OR:    expected_BusW = BusA | BusB;
                `ADD:   expected_BusW = BusA + BusB;
                `SUB:   expected_BusW = BusA - BusB;
                `PassB: expected_BusW = BusB;
                default: expected_BusW = 64'b0;
            endcase
            expected_Zero = (expected_BusW == 64'b0);
            #10;
            check_result(expected_BusW, expected_Zero, op, BusA, BusB);
            
            // Test at least one case that produces Zero=0
            case (op)
                `AND: begin
                    BusA = 64'hFFFFFFFFFFFFFFFF;
                    BusB = 64'hFFFFFFFFFFFFFFFF;
                end
                `OR: begin
                    BusA = 64'h0000000000000001;
                    BusB = 64'h0000000000000000;
                end
                `ADD: begin
                    BusA = 64'h0000000000000001;
                    BusB = 64'h0000000000000001;
                end
                `SUB: begin
                    BusA = 64'h0000000000000002;
                    BusB = 64'h0000000000000001;
                end
                `PassB: begin
                    BusB = 64'h0000000000000001;
                end
            endcase
            case (op)
                `AND:   expected_BusW = BusA & BusB;
                `OR:    expected_BusW = BusA | BusB;
                `ADD:   expected_BusW = BusA + BusB;
                `SUB:   expected_BusW = BusA - BusB;
                `PassB: expected_BusW = BusB;
                default: expected_BusW = 64'b0;
            endcase
            expected_Zero = (expected_BusW == 64'b0);
            #10;
            check_result(expected_BusW, expected_Zero, op, BusA, BusB);
            
            // Random tests (100 iterations)
            for (i = 0; i < 100; i = i + 1) begin
                BusA = {$random, $random};
                BusB = {$random, $random};
                
                case (op)
                    `AND:   expected_BusW = BusA & BusB;
                    `OR:    expected_BusW = BusA | BusB;
                    `ADD:   expected_BusW = BusA + BusB;
                    `SUB:   expected_BusW = BusA - BusB;
                    `PassB: expected_BusW = BusB;
                    default: expected_BusW = 64'b0;
                endcase
                expected_Zero = (expected_BusW == 64'b0);
                #10;
                check_result(expected_BusW, expected_Zero, op, BusA, BusB);
            end
        end
    endtask
    
    initial begin
        // Initialize VCD dump
        $dumpfile("alu.vcd");
        $dumpvars(0, ALU_tb);
        
        // Initialize counters
        errors = 0;
        total_tests = 0;
        
        $display("=== ALU Testbench Starting ===");
        $display("Testing with 100+ random values per operation");
        $display("");
        
        // Test each ALU operation
        test_operation(`AND, "AND");
        test_operation(`OR, "OR");
        test_operation(`ADD, "ADD");
        test_operation(`SUB, "SUB");
        test_operation(`PassB, "PassB");
        
        // Special test: ADD overflow
        $display("Testing ADD overflow...");
        ALUCtrl = `ADD;
        BusA = 64'hFFFFFFFFFFFFFFFF;
        BusB = 64'h0000000000000001;
        expected_BusW = BusA + BusB; // Will overflow to 0
        expected_Zero = (expected_BusW == 64'b0);
        #10;
        check_result(expected_BusW, expected_Zero, ALUCtrl, BusA, BusB);
        $display("  Overflow test: %h + %h = %h", BusA, BusB, BusW);
        
        // Another overflow test
        BusA = 64'hFFFFFFFFFFFFFFFF;
        BusB = 64'hFFFFFFFFFFFFFFFF;
        expected_BusW = BusA + BusB; // Will overflow
        expected_Zero = (expected_BusW == 64'b0);
        #10;
        check_result(expected_BusW, expected_Zero, ALUCtrl, BusA, BusB);
        $display("  Overflow test: %h + %h = %h", BusA, BusB, BusW);
        
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