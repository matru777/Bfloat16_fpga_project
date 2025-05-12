`timescale 1ns / 1ps

module bfloat_alu_tb;

    // Inputs
    reg [15:0] a;
    reg [15:0] b;
    reg [1:0] op;

    // Output
    wire [15:0] result;

    // Instantiate the Unit Under Test (UUT)
    bfloat_alu uut (
        .a(a),
        .b(b),
        .op(op),
        .result(result)
    );

    // Helper task to print BFloat16 details
    task print_result;
        input [1:0] op_code;
        input [15:0] a_val, b_val, res_val;
        reg [6:0] mantissa_a, mantissa_b, mantissa_res;
        reg [7:0] exponent_a, exponent_b, exponent_res;
        reg sign_a, sign_b, sign_res;
        begin
            sign_a = a_val[15];
            exponent_a = a_val[14:7];
            mantissa_a = a_val[6:0];

            sign_b = b_val[15];
            exponent_b = b_val[14:7];
            mantissa_b = b_val[6:0];

            sign_res = res_val[15];
            exponent_res = res_val[14:7];
            mantissa_res = res_val[6:0];

            $display("==========================================================");
            case(op_code)
                2'b00: $display("Operation: ADD");
                2'b01: $display("Operation: SUB");
                2'b10: $display("Operation: MUL");
                default: $display("Operation: UNKNOWN");
            endcase

            $display("Input A     = 0x%h | Sign: %b | Exp: %b | Mantissa: %b", a_val, sign_a, exponent_a, mantissa_a);
            $display("Input B     = 0x%h | Sign: %b | Exp: %b | Mantissa: %b", b_val, sign_b, exponent_b, mantissa_b);
            $display("Result      = 0x%h | Sign: %b | Exp: %b | Mantissa: %b", res_val, sign_res, exponent_res, mantissa_res);
            $display("==========================================================\n");
        end
    endtask
                
    initial begin
        // Test 1: ADD 1.5 + 2.5 (BFloat16: 0x3fc0 + 0x4020)
        a = 16'h3fc0; // 1.5
        b = 16'h4020; // 2.5
        op = 2'b00;   // ADD
        #10;
        print_result(op, a, b, result);

        // Test 2: SUB 5.5 - 3.0 (0x40b0 - 0x4040)
        a = 16'h40b0; // 5.5
        b = 16'h4040; // 3.0
        op = 2'b01;   // SUB
        #10;
        print_result(op, a, b, result);

        // Test 3: MUL 2.0 * 3.0 (0x4000 * 0x4040)
        a = 16'h4000; // 2.0
        b = 16'h4040; // 3.0
        op = 2'b10;   // MUL
        #10;
        print_result(op, a, b, result);

        // Test 4: ADD -1.25 + 2.25
        a = 16'hbf40; // -1.25
        b = 16'h4010; // 2.25
        op = 2'b00;
        #10;
        print_result(op, a, b, result);

        // Test 5: SUB 4.0 - 4.0
        a = 16'h4080; // 4.0
        b = 16'h4080; // 4.0
        op = 2'b01;
        #10;
        print_result(op, a, b, result);

        $finish;
    end
endmodule
