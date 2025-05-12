module addsub_tb;

    reg [15:0] a, b;
    reg operation;
    wire [15:0] result;

    addsub uut (
        .a(a),
        .b(b),
        .operation(operation),
        .result(result)
    );

    // Task to display inputs and outputs
    task print_result;
        input [15:0] a, b, result;
        input operation;
        begin
            $display("a = %h, b = %h, operation = %s, result = %h", 
                     a, b, operation ? "SUB" : "ADD", result);
        end
    endtask

    initial begin
        $display("Starting test...");

        // Test 1: 1.5 + 2.5 = 4.0 (normalized)
        a = 16'b0_01111111_1000000; // 1.5 in BF16
        b = 16'b0_10000000_0100000; // 2.5 in BF16
        operation = 1'b0; // ADD
        #10 print_result(a, b, result, operation);

        // Test 2: 5.0 - 3.0 = 2.0
        a = 16'b0_10000001_0100000; // 5.0
        b = 16'b0_10000000_1000000; // 3.0
        operation = 1'b1; // SUB
        #10 print_result(a, b, result, operation);

        // Test 3: -6.25 + 2.25 = -4.0
        a = 16'b1_10000001_1001000; // -6.25
        b = 16'b0_10000000_0010000; // 2.25
        operation = 1'b0; // ADD
        #10 print_result(a, b, result, operation);

        // Test 4: 4.5 - 1.5 = 3.0
        a = 16'b0_10000001_0010000; // 4.5
        b = 16'b0_01111111_1000000; // 1.5
        operation = 1'b1; // SUB
        #10 print_result(a, b, result, operation);

        // Test 5: -3.5 - 1.5 = -5.0
        a = 16'b1_10000000_1100000; // -3.5
        b = 16'b0_01111111_1000000; // 1.5
        operation = 1'b1; // SUB (→ -3.5 - 1.5 = -5.0)
        #10 print_result(a, b, result, operation);

        // Test 6: 2.5 - 1.5 = 1.0
        a = 16'h4020;  // 2.5 in BFloat16
        b = 16'h3FC0;  // 1.5 in BFloat16
        operation = 1; // SUB
        #10 print_result(a, b, result, operation);

        // Test 1: 1.0 + 2.0 = 3.0
        a = 16'h3F80;  // 1.0 in BFloat16
        b = 16'h4000;  // 2.0 in BFloat16
        operation = 0; // ADD
        #10 print_result(a, b, result, operation);

        // Test 2: -3.5 + 1.25 = -2.25
        a = 16'hC060;  // -3.5 in BFloat16
        b = 16'h3FA0;  // 1.25 in BFloat16
        operation = 0; // ADD
        #10 print_result(a, b, result, operation);

        // Test 3: 5.0 + (-1.0) = 4.0
        a = 16'h40A0;  // 5.0 in BFloat16
        b = 16'hBF80;  // -1.0 in BFloat16
        operation = 0; // ADD
        #10 print_result(a, b, result, operation);

        // --- Case A: 1.75 (0x3FE0) - 1.5 (0x3FC0) = 0.25 (0x3D80)
        a = 16'h3FE0;
        b = 16'h3FC0;
        operation = 1;  // Subtract
        #10 print_result(a, b, result, operation);

        // --- Case B: 1.25 (0x3FA0) - 1.0 (0x3F80) = 0.25 (0x3D80)
        a = 16'h3FA0;
        b = 16'h3F80;
        operation = 1;  // Subtract
        #10 print_result(a, b, result, operation);


        // --- Case C: 0.984375 (0x3F7C) + 0.015625 (0x3C80) ≈ 1.0 (0x3F80)
        a = 16'h3F7C;
        b = 16'h3C80;
        operation = 0;  // Add
        #10 print_result(a, b, result, operation);

        // Case: 1.015625 - 1.0 = 0.015625 → triggers leading zero normalization
        a = 16'h3F82;  // 1.015625
        b = 16'h3F80;  // 1.0
        operation = 1; // Subtraction
        #10 print_result(a, b, result, operation);

        a = 16'h0080;
        b = 16'h0040;
        operation = 1; // Subtract
        #10 print_result(a, b, result, operation);

        $display("Test completed.");
        $finish;
    end

endmodule
