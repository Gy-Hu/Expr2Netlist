// Benchmark "output" written by ABC on Sun Dec 24 20:14:28 2023

module output ( 
    a, b,
    F  );
  input  a, b;
  output F;
  wire new_n4_, new_n5_;
  INV      g0(.A(a), .Y(new_n4_));
  INV      g1(.A(b), .Y(new_n5_));
  NAND2    g2(.A(new_n5_), .B(new_n4_), .Y(F));
endmodule


