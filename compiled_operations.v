module bfloat_alu(
    input clk,
    output reg [15:0] result
);

wire [15:0] a[4:0];
wire [15:0] b[4:0];
wire [1:0]  op[4:0];

// Predefined inputs and operations
assign a[0] = 16'b0100001110000101; // 266
assign b[0] = 16'b0100000110001000; // 17
assign op[0] = 2'b10;               // multiply

assign a[1] = 16'b1100001001110011; // -60.75
assign b[1] = 16'b0011101111011110; // 0.00677
assign op[1] = 2'b10;

assign a[2] = 16'b0100010010111110; // 1520
assign b[2] = 16'b0100010011010110; // 1712
assign op[2] = 2'b00;               // add

assign a[3] = 16'b0100001100101001; // 169
assign b[3] = 16'b0100001100100011; // 163
assign op[3] = 2'b01;               // subtract

assign a[4] = 16'b0100000110001000; // 17
assign b[4] = 16'b1100000110001000; // -17
assign op[4] = 2'b01;

// Results of operations
wire [15:0] add_result[4:0];
wire [15:0] sub_result[4:0];
wire [15:0] mul_result[4:0];

addsub op1 (.a(a[0]), .b(b[0]), .operation(1'b0), .result(add_result[0]));
addsub op2 (.a(a[0]), .b(b[0]), .operation(1'b1), .result(sub_result[0]));
mul    op3 (.a(a[0]), .b(b[0]), .result(mul_result[0]));

addsub op4 (.a(a[1]), .b(b[1]), .operation(1'b0), .result(add_result[1]));
addsub op5 (.a(a[1]), .b(b[1]), .operation(1'b1), .result(sub_result[1]));
mul    op6 (.a(a[1]), .b(b[1]), .result(mul_result[1]));

addsub op7 (.a(a[2]), .b(b[2]), .operation(1'b0), .result(add_result[2]));
addsub op8 (.a(a[2]), .b(b[2]), .operation(1'b1), .result(sub_result[2]));
mul    op9 (.a(a[2]), .b(b[2]), .result(mul_result[2]));

addsub op10 (.a(a[3]), .b(b[3]), .operation(1'b0), .result(add_result[3]));
addsub op11 (.a(a[3]), .b(b[3]), .operation(1'b1), .result(sub_result[3]));
mul     op12 (.a(a[3]), .b(b[3]), .result(mul_result[3]));

addsub op13 (.a(a[4]), .b(b[4]), .operation(1'b0), .result(add_result[4]));
addsub op14 (.a(a[4]), .b(b[4]), .operation(1'b1), .result(sub_result[4]));
mul     op15 (.a(a[4]), .b(b[4]), .result(mul_result[4]));

// Counter to cycle through operations
reg [2:0] count = 0;

always @(posedge clk) begin
    case (op[count])
        2'b00: result <= add_result[count];
        2'b01: result <= sub_result[count];
        2'b10: result <= mul_result[count];
        default: result <= 16'b0;
    endcase

    if (count == 4)
        count <= 0;
    else
        count <= count + 1;
end

endmodule


module bfloat_unpack_for_addsub(
    input [15:0] a,b,
    output reg sign1, sign2,
    output reg [7:0] e1, e2,
    output reg [18:0] m1,m2
);
    always @(*)
    begin
        sign1 = a[15];
        sign2 = b[15];
        e1 = a[14:7];
        e2 = b[14:7];
        m1[18]=1'b0;
        m1[17]=1'b1;
        m1[16:10]= a[6:0];
        m1[9:0] = 10'b0;
        m2[18]=1'b0;
        m2[17]=1'b1;
        m2[16:10]= b[6:0];
        m2[9:0] = 10'b0;
    end
endmodule

module bfloat_pack_for_addsub(
    input sign,
    input [7:0] e,
    input [18:0] s,
    output reg [15:0] ans
);
    always @(*)
    begin
        ans[15]=sign;
        ans[14:7]=e;
        ans[6:0]=s[16:10];
    end
endmodule

module addsub(
    input [15:0] a,b,
    input operation, 
    output wire [15:0] result
);

    wire sign1_u, sign2_u , sign_u;
    wire [18:0] m1_u,m2_u,m_u;
    wire [7:0] e1_u,e2_u,e_u;
    bfloat_unpack_for_addsub u1(
        .a(a),
        .b(b),
        .sign1(sign1_u),
        .sign2(sign2_u),
        .e1(e1_u),
        .e2(e2_u),
        .m1(m1_u),
        .m2(m2_u)
    );

    reg sign1, sign2 , sign;
    reg [18:0] m1,m2,m;
    reg [7:0] e1,e2,e;

    //Temporary variables for swapping
    reg [7:0] temp_e;
    reg [18:0] temp_m;
    reg temp_sign;


    //For rounding 
    integer i;
    reg [4:0] k;
    reg p;
    reg guard;
    reg round_bit;
    reg sticky;
    reg found;

    always @(*)
    begin

        sign1=sign1_u;
        sign2=sign2_u;
        e1=e1_u;
        e2=e2_u;
        m1=m1_u;
        m2=m2_u;
          
        if(operation==1'b1) sign2=~sign2;
        if(e1<e2) 
        begin
            //swap(e1,e2);
            temp_e=e1;
            e1=e2;
            e2=temp_e;
            //swap(m1,m2);
            temp_m=m1;
            m1=m2;
            m2=temp_m;
            //swap(sign1,sign2);
            temp_sign=sign1;
            sign1=sign2;
            sign2=temp_sign;
        end
        e=e1;
        m2=m2>>(e1-e2);
        sign=sign1;
        if(sign^sign2==0)
        begin
            m=m1+m2;
            if(m[18]==1'b1)
            begin
                m=m>>1;
                e=e+1;
            end
        end
        else 
        begin
            if(e1==e2 && m1<m2)
            begin
                //swap(m1,m2);
                temp_m=m1;
                m1=m2;
                m2=temp_m;
                //swap(sign1,sign2);
                temp_sign=sign1;
                sign1=sign2;
                sign2=temp_sign;

                sign=~sign;
            end
            m=m1-m2;
            if(m[17]!=1'b1 && m[18]!=1'b1)
            begin
                //leading_zero l1(m,k);
                k=5'b00000;
                found=0;
                for(i=16;i>=0 && found==0 ;i=i-1)
                begin
                    if(m[i]==1'b1)
                    begin
                        k=17-i;
                        found=1;
                    end
                end
                m=m<<k;
                e=e-k;
            end
        end

        //Rounding
        // reg temp=m;
        // round_func r1(
        //     .m(temp),
        //     .m_rounded(m)
        // );

        p=m[10];
        guard=m[9];
        round_bit=m[8];
        sticky= |(m[7:0]);
        
        if(guard==1'b1)
        begin
            if(round_bit==1'b1 || sticky==1'b1)
            begin
                //m=m+11'b10000000000;
                m=m+19'b1<<10;
            end
            else if(p==1'b1)
            begin
                //m=m+11'b10000000000;
                m=m+19'b1<<10;
            end
        end


        if(m[18]==1'b1)
        begin
            m=m>>1;
            e=e+1;
        end

        if(found==1'b0)
        begin
            e=8'b0;
        end
    end
    bfloat_pack_for_addsub p1(
        .sign(sign),
        .e(e),
        .s(m),
        .ans(result)
    );
endmodule

module bfloat_unpack_for_mul(
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

module bfloat_pack_for_mul(
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

module mul(
    input [15:0] a,b,
    output wire [15:0] result
);

    // wire sign1_u, sign2_u , sign_u;
    // wire [18:0] m1_u,m2_u,m_u;
    // wire [7:0] e1_u,e2_u,e_u;
    wire sign1,sign2;
    //wire [18:0] m1,m2;
    wire [7:0] m1,m2;
    wire [8:0] e1,e2;
    bfloat_unpack_for_mul u1(
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

    // reg sign1, sign2 , sign;
    // reg [18:0] m1,m2,m;
    // reg [7:0] e1,e2,e;

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

        // sign1=sign1_u;
        // sign2=sign2_u;
        // e1=e1_u;
        // e2=e2_u;
        // m1=m1_u;
        // m2=m2_u;

        sign = sign1 ^ sign2;
        m = m1 * m2;
        e=e1+e2-127;
        // if(e>255)
        // begin
        //     e=255;
        // end
        // else if(e<0)
        // begin
        //     e=0;
        // end
        if(m[15]==1'b1)
        begin
            m=m>>1;
            e=e+1;
        end
        //No leading zero detection is required in bfloat muliplication
        //Reason is that product of 2 normalized nos, cannot be less than 1

        p=m[7];
        guard=m[6];
        round_bit=m[5];
        sticky= |(m[4:0]);
        
        if(guard==1'b1)
        begin
            if(round_bit==1'b1 || sticky==1'b1)
            begin
                //m=m+11'b10000000000;
                m=m+16'b1<<7;
            end
            else if(p==1'b1)
            begin
                //m=m+11'b10000000000;
                m=m+16'b1<<7;
            end
        end


        if(m[15]==1'b1)
        begin
            m=m>>1;
            e=e+1;
        end
    end
    bfloat_pack_for_mul p1(
        .sign(sign),
        .e(e),
        .s(m),
        .ans(result)
    );
endmodule