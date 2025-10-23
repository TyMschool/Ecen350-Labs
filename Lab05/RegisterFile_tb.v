`timescale 1ns/1ps

module tb_RegisterFile;

    // DUT interface signals
    reg  [63:0] BusW;
    reg  [4:0]  RA, RB, RW;
    reg         RegWr;
    reg         Clk;
    wire [63:0] BusA, BusB;


    // Instantiate the DUT
    RegisterFile dut (
        .BusA(BusA),
        .BusB(BusB),
        .BusW(BusW),
        .RA(RA),
        .RB(RB),
        .RW(RW),
        .RegWr(RegWr),
        .Clk(Clk)
    );


    // Golden model: stores expected register contents
    reg [63:0] golden [31:0];


    // Clock generator
    initial begin
        Clk = 0;
        forever #5 Clk = ~Clk;  // 10 ns period
    end

    initial begin
        $dumpfile("RegisterFile_tb.vcd");  // waveform file
        $dumpvars(0, tb_RegisterFile);     // dump all signals in this testbench
    end


    integer r;
    reg [63:0] rand_val;


    initial begin
        // Initialize golden registers
        for (r = 0; r < 32; r = r + 1)
            golden[r] = 64'd0;


        // Test with write enable ON
        $display("---- Testing with RegWr = 1 ----");
        RegWr = 1;
        for (r = 0; r < 32; r = r + 1) begin
            rand_val = $random;  // random 32-bit signed value
            rand_val = {rand_val, $random}; // make it 64-bit


            RW = r;
            BusW = rand_val;
            @(posedge Clk);  // perform write


            // Update golden model unless RW == 31
            if (r != 31) golden[r] = rand_val;


            // Read back via BusA
            RA = r;
            #10;  // allow #3 delay on BusA
            if (BusA !== golden[r]) begin
                $display("ERROR: Write enabled, Reg[%0d] expected %h, got %h", 
                         r, golden[r], BusA);
                $stop;
            end
        end


        // Test with write enable OFF
        $display("---- Testing with RegWr = 0 ----");
        RegWr = 0;
        for (r = 0; r < 32; r = r + 1) begin
            rand_val = {$random, $random}; // another random 64-bit value


            RW = r;
            BusW = rand_val;
            @(posedge Clk);  // attempt write, should not change regs

            // Read back via BusB
            RB = r;
            #10;  // allow #3 delay on BusB
            if (BusB !== golden[r]) begin
                $display("ERROR: Write disabled, Reg[%0d] expected %h, got %h", 
                         r, golden[r], BusB);
                $stop;
            end
        end

        $display("All randomized tests PASSED!");
        $finish;
    end

endmodule