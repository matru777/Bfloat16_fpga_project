`timescale 1ns / 1ps

module addsub_tb;

    // Inputs
    reg [15:0] a;
    reg [15:0] b;
    reg operation; // 0 = add, 1 = subtract

    // Output
    wire [15:0] result;

    // Instantiate the addsub module (your version)
    addsub uut (
        .a(a),
        .b(b),
        .operation(operation),
        .result(result)
    );

    // Task to show the results
    task print_result;
        input [15:0] a_in, b_in;
        input op;
        input [15:0] res;
        begin
            $display("Time: %0t | A = 0x%h | B = 0x%h | Op: %s | Result = 0x%h",
                      $time, a_in, b_in, op ? "SUB" : "ADD", res);
        end
    endtask

    initial begin
        $display("=== BFloat16 ADD/SUB Testbench ===");

        // Test 1: 1.5 + 2.25 = 3.75
        a = 16'b0100000110001000; // 17
        b = 16'b1100000110001000; // -17
        operation = 1;            // sub
        #20 print_result(a, b, operation, result);

        // Test 2: 5.0 - 3.0 = 2.0
        a = 16'b0100010010111110; // 1520
        b = 16'b0100010011010110; // 1712
        operation = 0;            // add
        #20 print_result(a, b, operation, result);

        // Test 3: 0.75 + 0.75 = 1.5
        a = 16'b0011111010000000; // 0.75
        b = 16'b0011111010000000; // 0.75
        operation = 0;            // ADD
        #20 print_result(a, b, operation, result);

        // Test 4: 7.0 - 2.5 = 4.5
        a = 16'b0100001110000000; // 7.0
        b = 16'b0100000100000000; // 2.5
        operation = 1;            // SUB
        #20 print_result(a, b, operation, result);

        // Test 5: 1.0 + (-1.0) = 0.0
        a = 16'b0011111110000000; // 1.0
        b = 16'b1011111110000000; // -1.0
        operation = 0;            // ADD
        #20 print_result(a, b, operation, result);

        $display("=== Testbench Complete ===");
        $finish;
    end

endmodule
