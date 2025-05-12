
module reciprocal(
    input [7:0] A,
    output reg [7:0] R
);
    reg[7:0] xn;
    reg[15:0] Axn;
    reg [15:0] diff;
    reg [15:0] pro;
    integer i;

    always@(*)
    begin
        xn=8'b01111111;
        for(i=0;i<3;i=i+1)
        begin
            Axn=A*xn;
            diff=16'b1000000000000000 - Axn;
            pro=xn*(diff>>7);
            xn=pro[14:7];
        end
        R=xn;
    end
endmodule


// module reciprocal(
//     input [7:0] A,          // Q1.7 format: 1.xxxxxxx
//     output reg [7:0] R      // Q1.7 output
// );

//     reg [7:0] xn;           // Current guess
//     reg [15:0] Axn;         // A * xn
//     reg [15:0] diff;        // 2 - Axn
//     reg [15:0] pro;         // xn * diff
//     integer i;

//     reg [15:0] TWO = 16'b0000001000000000; // 2.0 in Q2.14 format (512)

//     always @(*) begin
//         xn = 8'b01111111; // Initial guess ≈ 0.992 (in Q1.7)

//         for (i = 0; i < 3; i = i + 1) begin
//             Axn = A * xn;                  // A * xn => Q2.14
//             Axn = Axn >> 7;                // Normalize back to Q1.7
//             diff = TWO - (Axn >> 1);       // 2 - A*xn (Axn shifted to match scale)
//             pro = xn * diff;               // Multiply guess with diff
//             xn = pro[14:7];                // Normalize result back to Q1.7
//         end

//         R = xn; // Final reciprocal result
//     end
// endmodule
