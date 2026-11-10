# Run LibreLane locally

In this required lab, you will use LibreLane in our preinstalled Ubuntu VirtualBox environment to turn synthesizable Verilog into a physical ASIC layout and inspect it in KLayout. We will use SKY130 for this course.

Complete the RTL adaptation and functional tests in the [Tiny Tapeout guide](tiny-tapeout.md) before implementing your own design locally. This lab uses a general LibreLane configuration to explore physical implementation. For a submission-compatible local build, follow the official [Tiny Tapeout local hardening guide](https://tinytapeout.com/guides/local-hardening/).

## Contents

1. [Start the course virtual machine](#1-start-the-course-virtual-machine)
2. [Check the LibreLane environment](#2-check-the-librelane-environment)
3. [Collect project source files](#3-collect-the-project-source-files)
4. [Create the configuration](#4-create-the-configuration-file)
5. [Run implementation](#5-run-the-implementation-flow)
6. [Inspect the layout](#6-inspect-the-gdsii-layout)

[Troubleshooting](#troubleshooting)

## Before you begin

Have your synthesizable RTL, top-module name, passing functional tests, and intended clock frequency ready. Use the preinstalled course VM for this lab; you do not need to install Ubuntu, Nix, or LibreLane yourself.

## 0. Create a New Virtual Machine using the supplied VDI disk

1. Download the Ubuntu.vdi and place it in a local folder (not in OneDrive!)
2. Start 'Oracle VirtualBox Manager' 
3. Select 'Expert Mode' 
4. New Virtual Machine
5. 'Specify Virtual Hard Disk' -> Ubuntu.vdi (downloaded from OneDrive link on Canvas)
6. 'Specify virtual hardware'
  - base memory ~ 24,000 MB
  - Number of CPUs ~ 16 
7. Power-up/boot Ubuntu
8. Login: The username is vboxuser and the password is a single space. 


## 1. Start the course virtual machine

1. Open VirtualBox and start the preinstalled Ubuntu course VM.
2. Log in to Ubuntu and open **Terminal**.
3. Run all commands in this lab inside Ubuntu, rather than in a terminal on the host computer.

**Checkpoint:** Ubuntu starts and you can access your project files from Terminal.

## 2. Check the LibreLane environment

Enter the the librelane directory in a terminal, it is possible the terminal will start in this directory so `cd` may not be necessary:

```bash
cd ~/librelane
nix-shell
```
There may be an error stating that 'nixpkgs' was not found, this is OK as long as your prompt now has:
```bash
[nix-shell:~/librelane]$
```

Record the tool revision and run the smoke test:

```bash
git rev-parse HEAD
librelane --smoke-test
```
The smoke test will take about 2 minutes. Watch the text as it proceeds, we hope to learn some of the terminology. 

**Checkpoint:** The smoke test completes successfully. If it fails, save the errors and email me (Lucas and Prof. Tran) before continuing. Keep the installed tool version unchanged so we can reproduce the error.

## 3. Collect the project source files

Keep your project outside the LibreLane tool checkout. For this guide, use `~/my_designs/final_proj`:

```bash
mkdir -p ~/my_designs/final_proj
```

1. Copy the reusable RTL from your Vivado project into this directory. Use the design hierarchy to collect all required modules and headers.
2. Exclude simulation-only testbenches and FPGA-generated implementation files.
3. Resolve vendor-specific primitives, IP, or memory assumptions before implementation. It is unlikely that you have any of these. 
4. Check the exact top-module name and clock-port name in the RTL.

Use simple directory and filenames such as `final_proj` and `top_module.v` to keep the commands easy to follow. In these commands, `~` means your Ubuntu home directory.

**Checkpoint:** Every source dependency is available in the project directory, and the design passes its functional tests.

## 4. Create the configuration file

Create an empty file, then open it in your preferred text editor:

```bash
touch ~/my_designs/final_proj/config.json
```

Use this configuration structure and replace the filenames and settings with those for your design:

```json
{
  "DESIGN_NAME": "top_module",
  "VERILOG_FILES": [
    "dir::top_module.v",
    "dir::buttons.v",
    "dir::clock_div.v",
    "dir::draw.v",
    "dir::horizontal.v",
    "dir::position.v",
    "dir::speed_control.v",
    "dir::vertical.v"
  ],
  "CLOCK_PERIOD": 100,
  "CLOCK_PORT": "clk"
}
```

These filenames illustrate a multi-module project; the corresponding RTL is not included in this guide. Replace the module name, source list, and clock settings with your own; remove filenames that are not part of your design and add any required dependencies.

The [LibreLane configuration reference](https://librelane.readthedocs.io/en/stable/reference/configuration.html) explains how design files are resolved. The [flow-variable reference](https://librelane.readthedocs.io/en/stable/reference/common_flow_vars.html) defines the clock settings.

| Setting | Meaning |
| --- | --- |
| `DESIGN_NAME` | Exact name of the RTL top module, including capitalization |
| `VERILOG_FILES` | Source-file list; `dir::` resolves a path relative to this configuration's directory |
| `CLOCK_PORT` | Name of the top-level clock input |
| `CLOCK_PERIOD` | Target period in nanoseconds |

The example's 100 ns period corresponds to 10 MHz. Choose your project's target using the [clock-selection procedure](tiny-tapeout.md#choose-a-clock-and-tile-allocation), and use the corresponding period here. A simulation clock alone does not establish physical timing closure.

JSON requires double-quoted keys and strings, commas between entries, and no trailing comma after the final entry. Use the preinstalled environment's SKY130 (`sky130A`) process settings. Check the resolved PDK and standard-cell library in the run configuration and record them with your results.

**Checkpoint:** The JSON is valid, each listed file exists, and the module and clock names match the RTL.

## 5. Run the implementation flow

Use the Terminal session in which you entered `nix-shell`. If you opened a new Terminal, reenter the environment first:

```bash
cd ~/librelane
nix-shell
```

Run your project:

```bash
librelane ~/my_designs/final_proj/config.json
```

The tools translate RTL into cells, place those cells, build clock distribution where applicable, route the connections, and run implementation checks. Runtime depends on the design, constraints, hardware, and available resources.

If the run fails, read the first actionable error and its log, correct the underlying problem, and rerun the command. The LibreLane process exiting does not necessarily exit `nix-shell`; reenter the environment only if you have left it.

**Checkpoint:** The flow completes and you have identified the corresponding run directory. Preserve its logs and reports along with the source and configuration used.

## 6. Inspect the GDSII layout

After a successful run, open its layout using the command from the [official newcomers' tutorial](https://librelane.readthedocs.io/en/stable/getting_started/newcomers/index.html):

```bash
librelane --last-run --flow openinklayout ~/my_designs/final_proj/config.json
```

KLayout should open with the generated layout. If the most recent run failed, `--last-run` may select that incomplete run; resolve the failure before using this shortcut. Browse the layout and find three examples of CMOS gates that we have discussed in class. Capture screenshots that to submit. 

Locate the run's `final/` outputs and review its reports. Check timing, physical design rules (DRC), and layout-versus-schematic connectivity (LVS), along with other checks required by the flow. 

**Checkpoint:** You can show the layout and explain which implementation checks passed or have issues.

## Troubleshooting

| Symptom | What to check |
| --- | --- |
| `librelane` command not found | Enter the LibreLane Nix environment and rerun the smoke test. |
| Configuration file cannot be parsed | Check commas, double quotes, brackets, and the reported JSON line and column. |
| Top module cannot be found | Compare `DESIGN_NAME` with the module declaration and check that its file is listed. |
| Source path does not exist | Check capitalization, filename extensions, `dir::` paths, and the contents of the project directory. |
| Lint or syntax errors | Open the detailed lint log and fix the reported RTL error, such as a missing semicolon or unsupported construct. |
| Clock-related warnings or timing failures | Verify `CLOCK_PORT`, period units, generated clocks if any, and the actual constrained timing paths. |
| Layout viewer reports missing files | Confirm the selected run completed and produced the required layout outputs. |
| Environment runs out of memory or disk | Check the host and guest resources and design size before changing the configuration or rerunning. |

When you ask for help, provide the errors and the relevant configuration. Reinstalling the whole environment is almost always unnecessary when faced with an error.

## Questions / TODO 

1. How to summarize the data in runs/ , determine some of the key output files for students to inspect 
2. Need a much simpler design (4 bit counter), or adder 
3. Figure out how to simulate the extracted spice file 
4. With a simpler design locate some devices in the layout 

[← Tiny Tapeout guide](tiny-tapeout.md) · [Guide home](index.md)
