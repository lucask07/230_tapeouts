# Run LibreLane locally

In this tapeout lab, you will use LibreLane in our preinstalled Ubuntu VirtualBox environment to turn synthesizable four-bit adder Verilog into a physical ASIC layout and inspect it in KLayout. We will use [SKY130](https://skywater-pdk.readthedocs.io/en/main/index.html) for this course.

Complete section 1 "1. Identify the RTL you will reuse" from [Tiny Tapeout guide](tiny-tapeout.md) before implementing your own design locally. This lab uses a general LibreLane configuration to explore physical implementation. 

## Contents

1. [Start the course virtual machine](#1-start-the-course-virtual-machine)
2. [Check the LibreLane environment](#2-check-the-librelane-environment)
3. [Collect project source files](#3-collect-the-project-source-files)
4. [Create the configuration](#4-create-the-configuration-file)
5. [Run implementation](#5-run-the-implementation-flow)
6. [Inspect the layout](#6-inspect-the-gdsii-layout)

[Troubleshooting](#troubleshooting)

## Before you begin

Gather the resulable files from a Verilog project (.v design files) that you would like to test GDSII generation with, one example is your four bit adder from last week. Also be sure to have the top-module name of your design and the intended clock frequency (100 MHz is likely ok). 

## 0. Create a New Virtual Machine using the supplied VDI disk

1. Download the Ubuntu.vdi and place it in a local folder (not in OneDrive!)
2. Start 'Oracle VirtualBox Manager' 
3. Select 'Expert Mode' 
4. New Virtual Machine
5. 'Specify Virtual Hard Disk' -> Ubuntu.vdi (downloaded from the OneDrive link on Canvas)
6. 'Specify virtual hardware'
  - base memory ~ 24,000 MB
  - Number of CPUs ~ 16 
7. Power-up/boot Ubuntu
8. Login: The username is vboxuser and the password is a single space. 


## 1. Start the course virtual machine

1. Open VirtualBox and start the preinstalled Ubuntu course VM.
2. Log in to Ubuntu and open **Terminal**.
3. Run all commands in this lab inside Ubuntu, not in Windows.

**Checkpoint:** Ubuntu starts and you can access a Terminal.

## 2. Check the LibreLane environment

Enter the the librelane directory in a terminal (it is possible the terminal will start in this directory so `cd` may not be necessary) and enter the following commands.

```bash
cd ~/librelane
nix-shell
```

Your prompt should now show 
```bash
[nix-shell:~/librelane]$
```

Run the librelane smoke test:

```bash
git rev-parse HEAD
librelane --smoke-test
```
The smoke test will take about 2 minutes. Watch the text as it proceeds, you should start trying to learn some of the terminology. 

If the smoke test fails, you need to fix it before proceeding. If you can't correct the issue, save the errors and call us over or email us (Lucas, TA Adele Gillen, and Prof. Tran) before continuing. Keep the installed tool version unchanged so we can reproduce the error.

## 3. Collect the project source files

Keep your project outside the LibreLane tool checkout. For this guide, I'm using `~/my_designs/adder`:

```bash
mkdir -p ~/my_designs/adder
```

1. Copy the reusable RTL from your Vivado project into this directory.
2. Exclude simulation-only testbenches and FPGA-generated implementation files.
3. Resolve vendor-specific primitives, IP, or memory assumptions before implementation. It is unlikely that you have any of these. 
4. Check the exact top-module name and clock-port name in the RTL.

Use simple directory and filenames such as `adder` and `four_bit_adder.v` to keep the commands easy to follow. In these commands, `~` means your Ubuntu home directory.

## 4. Create the librelane configuration file

Create an empty config.json file (touch command), then open it in your preferred text editor:

```bash
touch ~/my_designs/adder/config.json
```

Use the configuration structure below and replace the filenames and settings with those for your design:

Here's an example, 
```json
{
  "DESIGN_NAME": "four_bit_adder",
  "VERILOG_FILES": [
    "dir::four_bit_adder.v",
    "dir::full_adder.v"
    ],
  "CLOCK_PERIOD": 100,
  "CLOCK_PORT": "clk",
  "DIE_AREA": "0 0 120 120",
  "CORE_AREA": "20 20 100 100",
  "FP_CORE_UTIL": 30
}
```

These filenames illustrate an example four bit adder circuit. Replace the module name, source list, and clock settings with your own; remove filenames that are not part of your design and add any required dependencies. Because a four bit adder is so small we have to force the area to be a bit larger so that the metal ties are big enough to pass design rule checking (DRC). This explains the settings of DIE_AREA, CORE_AREA, and FP_CORE_UTIL; these should be removed with larger more complex designs like your final project. Also, note that the four bit adder does not actually have a clock so the CLOCK_PORT configuration will be ignored and/or a warning will be issued. 

The [LibreLane configuration reference](https://librelane.readthedocs.io/en/stable/reference/configuration.html) explains how design files are resolved. The [flow-variable reference](https://librelane.readthedocs.io/en/stable/reference/common_flow_vars.html) defines the clock settings.

| Setting | Meaning |
| --- | --- |
| `DESIGN_NAME` | Exact name of the RTL **top** module, including capitalization |
| `VERILOG_FILES` | Source-file list; `dir::` resolves a path relative to this configuration's directory |
| `CLOCK_PORT` | Name of the top-level clock input |
| `CLOCK_PERIOD` | Target period in nanoseconds |

The example's 100 ns period corresponds to 10 MHz. Choose your project's target using the [clock-selection procedure](tiny-tapeout.md#choose-a-clock-and-tile-allocation), and use the corresponding period here. A simulation clock alone does not establish physical timing closure.

JSON requires double-quoted keys and strings, commas between entries, and no trailing comma after the final entry. Use the preinstalled environment's SKY130 (`sky130A`) process settings. Check the resolved PDK and standard-cell library in the run configuration and record them with your results.

**Checkpoint:** The JSON is valid, each listed file exists, and the module and clock names match the RTL.

## 5. Run the implementation flow

Use the Terminal session in which you entered `nix-shell`. If you opened a new Terminal, reenter the nix environment first:

```bash
cd ~/librelane
nix-shell
```

Run your project:

```bash
librelane ~/my_designs/adder/config.json
```

The tools translate RTL into cells, place those cells, build clock distribution where applicable, route the connections, and run implementation checks. Runtime depends on the design, constraints, hardware, and available resources.

If the run fails, carefully read the errors and its log, correct the underlying problem, and rerun the command. The LibreLane process exiting does not necessarily exit `nix-shell`; reenter the environment only if you have left it.

**Checkpoint:** The flow completes and you have identified the corresponding 'run/' directory. Preserve its logs and reports along with the source and configuration used.

## 6. Inspect the GDSII layout

After a successful run, open the layout using the command from the [official newcomers' tutorial](https://librelane.readthedocs.io/en/stable/getting_started/newcomers/index.html):

```bash
librelane --last-run --flow openinklayout ~/my_designs/final_proj/config.json
```

KLayout should open with the generated layout. If the most recent run failed, `--last-run` may select that incomplete run; resolve the failure before using this shortcut. Next, complete the items below as part of your "report" for this lab that you will submit to Canvas. 

1. Capture screenshots that you will submit to Canvas. 
2. Annotate the layout screenshot: label input/output pads. 
3. Zoom in and find an NMOS transitor. Capture a screenshot.
4. Zoom in and find a Boolean gate. Determine the type of gate and capture a screenshot.  

## 7. Review the output reports 

Navigate to the directory 'runs/' and then the most recent run (the folders are labeled by the date and time). Complete the questions below that you will submit in Canvas. 

1. Area and gate count in final/metrics.csv. Find and record cell count, gate count, and area.
2. Timing closure in 55-openroad-stapostpnr/summary.rpt (the number should be 55 but it might not be!). STA stands for static timing analysis. PNR stands for place and route. Report worst case setup and hold slack. A negative slack means that setup time or hold time failed. Why does this design not have relevant setup and hold time analysis?
3. Some reports are over *corners*. Review the librelane documentation to know what this means [corners](https://librelane.readthedocs.io/en/stable/usage/timing_corners.html). What is the 'tt' corner? What is the 'ff' corner? 


## Troubleshooting

| Symptom | What to check |
| --- | --- |
| `librelane` command not found | Enter the LibreLane Nix environment and rerun the smoke test. |
| Configuration file cannot be parsed | Check commas, double quotes, brackets, and the reported JSON line and column. |
| Top module cannot be found | Compare `DESIGN_NAME` with the module declaration and check that its file is listed. |
| Source path does not exist | Check capitalization, filename extensions, `dir::` paths, and the contents of the project directory. |
| Layout viewer reports missing files | Confirm the selected run completed and produced the required layout outputs. |

When you ask for help, provide the errors and the relevant configuration. Do not reinstall the librelane environment. 

[← Tiny Tapeout guide](tiny-tapeout.md) · [Guide home](index.md)
