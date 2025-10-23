`timescale 1ns/1ps

module tb_mux2to1_8;

    // Testbench signals
    reg  [7:0];
    reg  [7:0] in1;
    reg        sel;
    wire [7:0] out;

    // Instantiate the Device Under Test (DUT)
    mux2to1_8 dut (
        .in0(in0),
        .in1(in1),
        .sel(sel),
        .out(out)
    );

    // Test procedure
    initial begin
        // Create VCD file for waveform viewing
        $dumpfile("mux2to1_8_tb.vcd");
        $dumpvars(0, tb_mux2to1_8);

        // Exhaustively test all input combinations
        for (integer i0 = 0; i0 < 256; i0 = i0 + 1) begin
            for (integer i1 = 0; i1 < 256; i1 = i1 + 1) begin
                for (integer s = 0; s < 2; s = s + 1) begin
                    in0 = i0[7:0];
                    in1 = i1[7:0];
                    sel = s[0];
                    
                    #5; // Wait 5 ticks before checking

                    // Display stimulus and output
                    $display("Time=%0t | in0=%h | in1=%h | sel=%b | out=%h", 
                              $time, in0, in1, sel, out);

                    // Self-check
                    if (out !== (sel ? in1 : in0)) begin
                        $display("ERROR: Expected %h, got %h", 
                                 (sel ? in1 : in0), out);
                        $stop;  // Stop simulation on error
                    end
                end
            end
        end

        $display("All tests passed!");
        $finish;
    end

endmodule

