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

module addsub(
    input [15:0] a,b,
    input operation, 
    output wire [15:0] result
);

    wire sign1_u, sign2_u , sign_u;
    wire [18:0] m1_u,m2_u,m_u;
    wire [7:0] e1_u,e2_u,e_u;
    bfloat_unpack u1(
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
    end
    bfloat_pack p1(
        .sign(sign),
        .e(e),
        .s(m),
        .ans(result)
    );
endmodule

// module round_func(
//     input reg [18:0] m,
//     output reg [18:0] m_rounded
// );

//     reg p=m[10];
//     reg guard=m[9];
//     reg round=m[8];
//     reg sticky= |(m[7:0]);
//     always @(*)
//     begin
//         if(guard==1'b1)
//         begin
//             if(round==1'b1 || sticky==1'b1)
//             begin
//                 m_rounded=m+11'b10000000000;
//             end
//             else if(p==1'b1)
//             begin
//                 m_rounded=m+11'b10000000000;
//             end
//             else
//             begin
//                 m_rounded=m;
//             end
//         end
//         else
//         begin
//             m_rounded=m;
//         end
//     end
// endmodule

// module leading_zero(
//     input reg [18:0] m,
//     output reg [4:0] k
// );
//     integer i;
//     always @(*)
//     begin
//         k=5'b00000;
//         for(i=16;i>=0;i=i-1)
//         begin
//             if(m[i]==1'b1)
//             begin
//                 k=17-i;
//                 break;
//             end
//         end
//     end
// endmodule




