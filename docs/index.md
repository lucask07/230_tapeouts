# From a Verilog FPGA project to Tiny Tapeout

In this course, we will adapt a Verilog FPGA design for a SKY130 application-specific integrated circuit (ASIC), generate its physical layout in GDSII format, and prepare it for Tiny Tapeout submission.

Start with your project's **RTL source files**, which describe the hardware. The ASIC tools synthesize that description into standard cells and connect those cells in a physical layout. Your FPGA bitstream is not used in this process.

## Course workflow

| Guide | What you will do |
| --- | --- |
| [Prepare a Tiny Tapeout project](tiny-tapeout.md) | Adapt your FPGA RTL, configure the SKY130 repository, test the design, and generate GDSII with GitHub Actions. Start here. |
| [Run LibreLane locally](librelane.md) | Use the preinstalled Ubuntu VirtualBox environment to run a local ASIC flow and inspect the layout in KLayout. This lab is required. |

Complete both parts. The local lab teaches physical implementation, while the Tiny Tapeout template provides the supported submission flow. You do not need to install LibreLane yourself.

## Before you begin

You should be able to identify your Verilog top module, describe its inputs and outputs, and explain how its clock and reset work. Have your source files and an account on [GitHub](https://github.com/) available.

All projects will use the [SKY130 Verilog template](https://github.com/TinyTapeout/ttsky-verilog-template). Select tiles based on your project's implementation needs and choose a clock using the [clock-selection procedure](tiny-tapeout.md#choose-a-clock-and-tile-allocation). Use the preinstalled Ubuntu course VM for local work. Adapt example module names and pin mappings to your design.

For now, finish with a submission-ready project. Fabrication submission arrangements are not yet finalized, so the guide stops before placing an order or submitting a revision.

## Guide status

The instructions have been reviewed against official documentation. A complete course example has not yet been run through the guides.

[Repository home](../README.md) · [Start the Tiny Tapeout guide →](tiny-tapeout.md)
