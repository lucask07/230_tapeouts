# From a Verilog FPGA project to Tiny Tapeout

Use these guides to adapt a Verilog design for an application-specific integrated circuit (ASIC), generate its physical layout in GDSII format, and prepare a Tiny Tapeout submission.

Start with your project's **RTL source files**, which describe the hardware. The ASIC tools synthesize that description into standard cells and connect those cells in a physical layout. Your FPGA bitstream is not used in this process.

## Choose a guide

| Guide | What you will do |
| --- | --- |
| [Prepare a Tiny Tapeout project](tiny-tapeout.md) | Adapt your FPGA RTL, configure a submission repository, test the design, generate GDSII with GitHub Actions, and submit a revision. Start here. |
| [Run LibreLane locally](librelane.md) | Set up Ubuntu and Nix, run RTL through a local ASIC flow, and inspect the layout in KLayout. This is a companion lab. |

You can follow the GitHub Actions guide without first installing LibreLane on your computer. A general local LibreLane run teaches physical implementation; use Tiny Tapeout's supported flow for submission-compatible results.

## Before you begin

You should be able to identify your Verilog top module, describe its inputs and outputs, and explain how its clock and reset work. Have your source files and an account on [GitHub](https://github.com/) available.

These guides retain the original course references' SKY130 and Vivado/Basys 3 context. Confirm the target shuttle, clock requirements, tile budget, and any required local environment with your instructor. The examples show how to edit files; adapt names and values to your project.

## Status and sources

This first Markdown edition was checked against official documentation on October 28, 2026. The commands and examples have not yet been validated through a complete student design build. A course template revision and tested local tool version still need to be selected.

The original Word files remain in [starting_references](../starting_references/). See the [project plan and technical review](project-plan.md) for corrections made during conversion and the remaining validation work.

[Repository home](../README.md) · [Start the Tiny Tapeout guide →](tiny-tapeout.md)
