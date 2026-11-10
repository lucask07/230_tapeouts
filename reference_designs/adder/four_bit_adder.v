`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// 
//////////////////////////////////////////////////////////////////////////////////
module four_bit_adder (
        input C0,
        input [3:0] A,
        input [3:0] B,
        output [4:0] S
    );
    
    wire t1, t2, t3;
    
    full_adder U1(.Cin(C0), .A(A[0]), .B(B[0]), .S(S[0]), .Cout(t1));
    full_adder U2(.Cin(t1), .A(A[1]), .B(B[1]), .S(S[1]), .Cout(t2));
    full_adder U3(.Cin(t2), .A(A[2]), .B(B[2]), .S(S[2]), .Cout(t3));
    full_adder U4(.Cin(t3), .A(A[3]), .B(B[3]), .S(S[3]), .Cout(S[4]));
endmodule
