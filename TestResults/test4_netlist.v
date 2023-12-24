// Benchmark "output" written by ABC on Sun Dec 24 20:15:09 2023

module output ( 
    a, b,
    F  );
  input  a, b;
  output F;
  NAND2    g0(.A(b), .B(a), .Y(F));
endmodule


