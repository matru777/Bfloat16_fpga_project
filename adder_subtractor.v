module bfloat_unpack(
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

module bfloat_pack(
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

module round_func(
    input [18:0] m,
    output reg [18:0] m_rounded
);

    reg p=m[10];
    reg guard=m[9];
    reg round=m[8];
    reg sticky= |(m[7:0]);
    always @(*)
    begin
        if(guard==1'b1)
        begin
            if(round==1'b1 || sticky==1'b1)
            begin
                m_rounded=m+11'b10000000000;
            end
            else if(p==1'b1)
            begin
                m_rounded=m+11'b10000000000;
            end
            else
            begin
                m_rounded=m;
            end
        end
        else
        begin
            m_rounded=m;
        end
    end
endmodule

module leading_zero(
    input [18:0] m,
    output reg [4:0] k
);
    integer i;
    always @(*)
    begin
        k=5'b00000;
        for(i=16;i>=0;i=i-1)
        begin
            if(m[i]==1'b1)
            begin
                k=17-i;
                break;
            end
        end
    end
endmodule

module addsub(
    input [15:0] a,b,
    input operation, 
    output reg [15:0] result
);

    reg sign1, sign2 , sign;
    reg [18:0] m1,m2,m;
    reg [7:0] e1,e2,e;
    bfloat_unpack u1(
        .a(a),
        .b(b),
        .sign1(sign1),
        .sign2(sign2),
        .e1(e1),
        .e2(e2),
        .m1(m1),
        .m2(m2)
    );
    

    always @(*)
    begin  
        if(operation==1'b1) sign2=~sign2;
        if(e1<e2) 
        begin
            // swap(e1,e2);
            // swap(m1,m2);
            // swap(sign1,sign2);
            tmp_e = e1; e1 = e2; e2 = tmp_e;
            tmp_m = m1; m1 = m2; m2 = tmp_m;
            tmp_s = sign1; sign1 = sign2; sign2 = tmp_s;
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
                // swap(m1,m2);
                // swap(sign1,sign2);
                tmp_m = m1; m1 = m2; m2 = tmp_m;
                sign=~sign;
            end
            m=m1-m2;

            if(m[17]!=1'b1 && m[18]!=1'b1)
            begin
                m=m<<k;
                e=e-k;
            end
        end
        if(m[18]==1'b1)
        begin
            m=m>>1;
            e=e+1;
        end
    end
    bfloat_pack p1(
        .sign(sign),
        .e(e),
        .s(m),
        .ans(result)
    );
endmodule






