module bfloat_unpack(
    input [15:0] a,b,
    output reg sign1, sign2,
    output reg [8:0] e1, e2,
    //output reg [18:0] m1,m2
    output reg [7:0] m1,m2
);
    always @(*)
    begin
        sign1 = a[15];
        sign2 = b[15];
        e1 = a[14:7];
        e2 = b[14:7];
        // m1[18]=1'b0;
        // m1[17]=1'b1;
        // m1[16:10]= a[6:0];
        // m1[9:0] = 10'b0;
        // m2[18]=1'b0;
        // m2[17]=1'b1;
        // m2[16:10]= b[6:0];
        // m2[9:0] = 10'b0;
        //m1[8]=1'b0;
        m1[7]=1'b1;
        m1[6:0]= a[6:0];
        //m2[8]=1'b0;
        m2[7]=1'b1;
        m2[6:0]= b[6:0];
    end
endmodule

module bfloat_pack(
    input sign,
    input [8:0] e,
    // input [37:0] s,
    input [15:0] s,
    output reg [15:0] ans
);
    always @(*)
    begin
        ans[15]=sign;
        ans[14:7]=e[7:0];
        //ans[6:0]=s[16:10];
        //ans[6:0]=s[35:29];
        ans[6:0]=s[13:7];
    end
endmodule

module div(
    input [15:0] a,b,
    output wire [15:0] result
);

    wire sign1,sign2;
    //wire [18:0] m1,m2;
    wire [7:0] m1,m2;
    wire [8:0] e1,e2;
    bfloat_unpack u1(
        .a(a),
        .b(b),
        // .sign1(sign1_u),
        // .sign2(sign2_u),
        // .e1(e1_u),
        // .e2(e2_u),
        // .m1(m1_u),
        // .m2(m2_u)
        .sign1(sign1),
        .sign2(sign2),
        .e1(e1),
        .e2(e2),
        .m1(m1),
        .m2(m2)
    );

    reg sign;
    reg [15:0] m;
    //reg [37:0] m;
    reg [8:0] e;

    //For rounding 
    integer i;
    reg p;
    reg guard;
    reg round_bit;
    reg sticky;
    reg found;

    always @(*)
    begin

        sign = sign1 ^ sign2;
        m = m1 / m2;
        e=e1-e2+127;

        // if(m[14]==1'b0)
        // begin
        //     m=m<<1;
        //     e=e-1;
        // end

        // p=m[7];
        // guard=m[6];
        // round_bit=m[5];
        // sticky= |(m[4:0]);
        
        // if(guard==1'b1)
        // begin
        //     if(round_bit==1'b1 || sticky==1'b1)
        //     begin
        //         //m=m+11'b10000000000;
        //         m=m+16'b1<<7;
        //     end
        //     else if(p==1'b1)
        //     begin
        //         //m=m+11'b10000000000;
        //         m=m+16'b1<<7;
        //     end
        // end
    end
    bfloat_pack p1(
    .sign(sign),
    .e(e),
    .s(m),
    .ans(result)
);
endmodule