// Benchmark "output" written by ABC on Sun Dec 24 20:16:28 2023

module output ( 
    a, b, c, d, e,
    F  );
  input  a, b, c, d, e;
  output F;
  wire new_n7_, new_n8_, new_n9_, new_n10_, new_n11_;
  INV      g0(.A(e), .Y(new_n7_));
  INV      g1(.A(c), .Y(new_n8_));
  NAND2    g2(.A(d), .B(new_n8_), .Y(new_n9_));
  NOR2     g3(.A(new_n9_), .B(new_n7_), .Y(new_n10_));
  NAND2    g4(.A(b), .B(a), .Y(new_n11_));
  NOR2     g5(.A(new_n11_), .B(new_n10_), .Y(F));
endmodule


