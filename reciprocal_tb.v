`timescale 1ns/1ps

module reciprocal_tb;

    reg [7:0] A;       
    wire [7:0] R;            

    reciprocal uut (
        .A(A),
        .R(R)
    );

    task print_result;
        input [7:0] in_A, out_R;
        begin
            $display("A = %b (%0d in decimal), Reciprocal = %b (%0d in decimal)", in_A, in_A, out_R, out_R);
        end
    endtask

    initial begin
        $display("Reciprocal Calculation Testbench");
        $display("-------------------------------");

        // Test case 1: Reciprocal of 1.0
        A = 8'b01000000; // 1.0 in Q1.7
        #10 print_result(A, R);

        // Test case 2: Reciprocal of 0.5
        A = 8'b01000000; // 0.5 in Q1.7
        #10 print_result(A, R);

        // Test case 3: Reciprocal of 2.0
        A = 8'b10000000; // 2.0 in Q1.7
        #10 print_result(A, R);

        // Test case 4: Reciprocal of 0.75
        A = 8'b01100000; // 0.75 in Q1.7
        #10 print_result(A, R);

        // Test case 5: Reciprocal of 1.25
        A = 8'b10100000; // 1.25 in Q1.7
        #10 print_result(A, R);

        // Test case 6: Reciprocal of 0.25
        A = 8'b00100000; // 0.25 in Q1.7
        #10 print_result(A, R);

        // Test case 7: Reciprocal of 1.5
        A = 8'b11000000; // 1.5 in Q1.7
        #10 print_result(A, R);

        // Test case 8: Reciprocal of 0.875
        A = 8'b01111000; // 0.875 in Q1.7
        #10 print_result(A, R);

        $finish;
    end

endmodule
