`timescale 1ns / 1ps

module bfloat_alu_tb;

  reg clk;
  wire [15:0] result;

  bfloat_alu uut (
    .clk(clk),
    .result(result)
  );

  initial begin
    clk = 0;
    forever #5 clk = ~clk; 
  end

  // Test procedure
  initial begin
    
    $display("Time\tResult (Hex)");
    
    
    $monitor("%0t\t%h", $time, result);
    
    
    
    #1000;  
    
    
    $stop;
  end

endmodule


// `timescale 1ns / 1ps

// module bfloat_alu_tb;

//   reg clk;
//   wire [15:0] result;
//   wire [15:0] m_before, m_after;

//   // Instantiate the bfloat_alu module
//   bfloat_alu uut (
//     .clk(clk),
//     .result(result),
//     .m_before_rounding(m_before),
//     .m_after_rounding(m_after)
//   );

//   // Clock generation
//   initial begin
//     clk = 0;
//     forever #5 clk = ~clk; // 100 MHz clock
//   end

//   // Test procedure
//   initial begin
//     $display("Time\t\tResult (Hex)\tMantissa Before Rounding\tMantissa After Rounding");
//     $monitor("%0t\t%h\t\t%b\t\t\t%b", $time, result, m_before, m_after);
    
//     #1000;  // Run simulation
//     $stop;
//   end

// endmodule
