// `timescale 1ns/1ps

// module mul_tb;

//   reg [15:0] a, b;
//   wire [15:0] result;

//   // Instantiate the multiplication module
//   mul uut (
//     .a(a),
//     .b(b),
//     .result(result)
//   );

//   // Task to display the BFloat16 inputs/outputs in a more readable way
//   task print_result;
//     input [15:0] in_a, in_b, out_result;
//     begin
//       $display("A = 0x%h, B = 0x%h, A * B = 0x%h", in_a, in_b, out_result);
//     end
//   endtask

//   initial begin
//     $display("BFloat16 Multiplication Test");
//     $display("-----------------------------");

//     // Test case 1: 266 * 17 = 4522(Expected) 4512(Observed)
//     // a = 16'h4385; // 266
//     // b = 16'h4188; // 17
//     // #10 print_result(a, b, result);

//     // // Test case 2: -2.0 * 3.0 = -6.0
//     // a = 16'hC000; // -2.0
//     // b = 16'h4040; // 3.0
//     // #10 print_result(a, b, result);

//     // // Test case 3: 0.5 * 4.0 = 2.0
//     // a = 16'h3f00; // 0.5
//     // b = 16'h4080; // 4.0
//     // #10 print_result(a, b, result);

//     // // Test case 4: 1.5 * 1.5 = 2.25
//     // a = 16'h3fc0; // 1.5
//     // b = 16'h3fc0; // 1.5
//     // #10 print_result(a, b, result);

//     // // Test case 5: 0.51 * 2.0
//     // a = 16'h3f06; // ~0.51
//     // b = 16'h4000; // 2.0
//     // #10 print_result(a, b, result);

//     a = 16'h3ccd; // 1.73
//     b = 16'hc246; // 217.9
//     #10 print_result(a, b, result);

//     $finish;
//   end

// endmodule



`timescale 1ns/1ps

module mul_tb;

  reg [15:0] a, b;
  wire [15:0] result;
  wire [15:0] m_mul, m_nor, m_round;

  // Instantiate the multiplication module
  mul uut (
    .a(a),
    .b(b),
    .result(result),
    .m_mul(m_mul),
    .m_nor(m_nor),
    .m_round(m_round)
  );

  // Task to display the BFloat16 inputs/outputs at each stage
  task print_result;
    input [15:0] in_a, in_b, out_result;
    input [15:0] mul_raw, mul_norm, mul_rounded;
    begin
      $display("A       = 0x%h", in_a);
      $display("B       = 0x%h", in_b);
      $display("m_mul   = 0x%h (raw product)", mul_raw);
      $display("m_nor   = 0x%h (after normalization)", mul_norm);
      $display("m_round = 0x%h (after rounding)", mul_rounded);
      $display("Result  = 0x%h", out_result);
      $display("---------------------------------------------------");
    end
  endtask

  initial begin
    $display("BFloat16 Multiplication Test");
    $display("---------------------------------------------------");

    // Test Case: 1.73 * -217.9
    a = 16'h3ccd; // ~1.73
    b = 16'hc246; // ~-217.9
    #10 print_result(a, b, result, m_mul, m_nor, m_round);

    // Add more test cases here if needed...

    $finish;
  end

endmodule
