// Benchmark "output" written by ABC on Sun Dec 24 20:06:53 2023

module output ( 
    a, b,
    F  );
  input  a, b;
  output F;
  wire new_n4_;
  INV      g0(.A(a), .Y(new_n4_));
  NOR2     g1(.A(b), .B(new_n4_), .Y(F));
endmodule


