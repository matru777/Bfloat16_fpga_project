BFloat16 Arithmetic Operations on FPGA

This project implements arithmetic operations using the BFloat16 floating-point format on an FPGA using Verilog. The operations supported are:

- BFloat16 Addition
- BFloat16 Subtraction
- BFloat16 Multiplication

The design is synthesizable and tested for deployment on FPGA boards (e.g., Basys 3). The implementation is modular, enabling easy extension to include division or fused operations in future.

---

What is BFloat16?

BFloat16 (Brain Floating Point) is a 16-bit floating-point representation widely used in machine learning due to its balance of range and precision:

- 1 sign bit
- 8 exponent bits (same as IEEE 754 single precision)
- 7 mantissa bits

This format preserves the dynamic range of `float32` while reducing memory and compute requirements.
