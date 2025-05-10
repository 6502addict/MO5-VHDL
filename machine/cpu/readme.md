# CPU09 - 6809-Compatible CPU Core in VHDL

This directory contains `cpu09.vhd`, the CPU core component of John Kent's System09 project.

## Overview

The CPU09 is a VHDL implementation of a Motorola 6809-compatible CPU core. It provides complete instruction set compatibility with the original 6809 microprocessor while being synthesizable for FPGA implementations.

## Original Source

This file is part of the System09 project, a complete 6809 System-on-Chip that emulates the SWTPc 6809 computer system. The original project was created and maintained by John Kent and can be found at:

- Project homepage: [System09 on OpenCores](https://opencores.org/projects/system09)
- Original website: [John Kent's System09 Page](http://members.optusnet.com.au/jekent/system09)

## Features

- Complete 6809 instruction set compatibility
- Synthesizable VHDL code
- Used in numerous FPGA implementations
- Well-tested in various boards and configurations

## License

This code is released under the GPL license as per the original System09 project.

## Integration

This core forms the central CPU component of a System09 implementation and has been used in various FPGA platforms including:

- Xilinx Spartan series boards
- Altera/Intel platforms (including the DE1)
- XESS boards
- Digilent development boards
- BurchED FPGA boards

## Credits

Originally developed by John Kent as part of the System09 project, which has been active since May 2003.

## Usage in MO5 Implementation

In this project, the CPU09 core is used as the processor for the Thomson MO5 FPGA implementation, demonstrating its versatility beyond its original System09 design.
