`timescale 1ns / 1ps

module div_tb;

  // Inputs
  reg [15:0] a, b;

  // Output
  wire [15:0] result;

  // Instantiate the Unit Under Test (UUT)
  div uut (
    .a(a), 
    .b(b), 
    .result(result)
  );

  // Task to display in float-like format
  task display_result;
    input [15:0] in;
    reg sign;
    reg [7:0] exponent;
    reg [6:0] mantissa;
    begin
      sign = in[15];
      exponent = in[14:7];
      mantissa = in[6:0];
      $display("BFloat16 = 0x%h => sign: %b, exp: %d, mant: 1.%b", in, sign, exponent, mantissa);
    end
  endtask

  initial begin
    $display("----- BFloat16 Division Testbench -----");

    // Example: 6.0 / 3.0 => 2.0
    a = 16'h40C0; // 6.0
    b = 16'h4040; // 3.0
    #10;
    $display("6.0 / 3.0 = ");
    display_result(result);

    // Example: 4.0 / 2.0 => 2.0
    a = 16'h4080; // 4.0
    b = 16'h4000; // 2.0
    #10;
    $display("4.0 / 2.0 = ");
    display_result(result);

    // Example: 1.0 / 2.0 => 0.5
    a = 16'h3f80;
    b = 16'h4000;
    #10;
    $display("1.0 / 2.0 = ");
    display_result(result);

    // Example: 2.0 / 1.0 => 2.0
    a = 16'h4000;
    b = 16'h3f80;
    #10;
    $display("2.0 / 1.0 = ");
    display_result(result);

    // Example: 5.0 / 2.0 => 2.5
    a = 16'h40A0; // 5.0
    b = 16'h4000; // 2.0
    #10;
    $display("5.0 / 2.0 = ");
    display_result(result);

    $stop;
  end
endmodule
