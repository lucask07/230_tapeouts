# Run LibreLane locally

Use LibreLane to turn synthesizable Verilog into a physical ASIC layout on your computer, then inspect that layout in KLayout. This companion lab explains installation, configuration, execution, and troubleshooting.

It is based on the [original LibreLane Word instructions](../starting_references/LibreLane_Documentation.docx). For a Tiny Tapeout submission, start with the [Tiny Tapeout guide](tiny-tapeout.md). A general LibreLane configuration does not include all shuttle-specific requirements; use the official [Tiny Tapeout local hardening guide](https://tinytapeout.com/guides/local-hardening/) when building a submission locally.

## Contents

1. [Prepare Ubuntu](#1-prepare-ubuntu)
2. [Install Nix and LibreLane](#2-install-nix-and-enter-the-librelane-environment)
3. [Collect project source files](#3-collect-the-project-source-files)
4. [Create the configuration](#4-create-the-configuration-file)
5. [Run implementation](#5-run-the-implementation-flow)
6. [Inspect the layout](#6-inspect-the-gdsii-layout)

[Troubleshooting](#troubleshooting)

## Before you begin

Have synthesizable RTL, its top-module name, a working functional test, and a known clock requirement. Decide whether this lab will run in an existing Linux environment or in an Ubuntu virtual machine (VM).

The instructions below retain the Word document's Ubuntu-in-VirtualBox route. Official [Nix installation instructions](https://librelane.readthedocs.io/en/stable/installation/nix_installation/index.html) also cover Windows through WSL and macOS. Follow the route assigned for your course rather than combining installation methods.

## 1. Prepare Ubuntu

Skip this section if your instructor has provided a suitable Ubuntu environment.

1. Install [Oracle VirtualBox](https://www.virtualbox.org/wiki/Downloads) if your computer supports the course's VM configuration.
2. Download the Ubuntu ISO assigned by your instructor from [Ubuntu releases](https://releases.ubuntu.com/). Match the guest architecture to your supported host setup; an Intel/AMD image is not a universal choice for every computer.
3. In VirtualBox, select **New** or **Create a new virtual machine**, depending on your version.
4. Enter a VM name, choose a storage location, and select the ISO image.
5. Configure your Ubuntu username and password if using unattended installation. Otherwise, enter them during the Ubuntu installer.
6. Allocate CPU, memory, and disk resources that fit your host while leaving capacity for the host operating system. Use the course's tested allocation when available.
7. Start the VM and complete Ubuntu setup. Open **Terminal** after logging in.

The [official LibreLane Linux requirements](https://librelane.readthedocs.io/en/stable/installation/nix_installation/installation_linux.html) list 8 GiB of RAM as a minimum and 16 GiB as recommended, with a quad-core CPU as the minimum CPU guidance. A VM must fit within the host's resources, and large designs can require more. Allow storage for Ubuntu, tools, the process design kit, and multiple implementation runs.

The original document's 25–31 GB memory allocation and six CPUs described one setup; they are not universal requirements. Ask your instructor for a supported environment if your computer cannot provide the needed resources.

**Checkpoint:** Ubuntu starts reliably, Terminal works, and the environment has network access and available disk space.

## 2. Install Nix and enter the LibreLane environment

Run the following commands **in Ubuntu Terminal**, not in a Windows command prompt or on the host by accident. These steps follow LibreLane's [Ubuntu installation guide](https://librelane.readthedocs.io/en/stable/installation/nix_installation/installation_linux.html).

### Install the prerequisite tools

```bash
sudo apt-get update
sudo apt-get install -y curl git
```

### Install Nix

For a new Nix installation, use the official guide's installer and cache configuration:

```bash
curl --proto '=https' --tlsv1.2 -fsSL https://artifacts.nixos.org/nix-installer | sh -s -- install --no-confirm --extra-conf "
    extra-substituters = https://nix-cache.fossi-foundation.org
    extra-trusted-public-keys = nix-cache.fossi-foundation.org:3+K59iFwXqKsL7BNu6Guy0v+uTlwsxYQxjspXzqLYQs=
    extra-experimental-features = nix-command flakes
"
```

Enter your Ubuntu password if prompted. When installation finishes, close Terminal and open a new Terminal window. If Nix is already installed, follow the official guide's existing-installation instructions to configure the cache and features.

### Download LibreLane

```bash
git clone https://github.com/librelane/librelane.git ~/librelane
cd ~/librelane
git rev-parse HEAD
nix-shell
```

Record the commit printed by `git rev-parse HEAD`. If your instructor specifies a release or commit, check out that revision before entering `nix-shell`. If `~/librelane` already exists, inspect the existing checkout instead of cloning over it.

The first environment setup downloads dependencies and may take some time. When it finishes, run:

```bash
librelane --smoke-test
```

**Checkpoint:** The smoke test completes successfully. A changed shell prompt alone does not prove the installation works. Stop and diagnose installation errors before running your own design.

## 3. Collect the project source files

Keep your project outside the LibreLane tool checkout. For this guide, use `~/my_designs/final_proj`:

```bash
mkdir -p ~/my_designs/final_proj
```

1. Copy the reusable RTL from your Vivado project into this directory. Use the design hierarchy to collect all required modules and headers.
2. Exclude simulation-only testbenches and FPGA-generated implementation files.
3. Resolve vendor-specific primitives, IP, or memory assumptions before implementation.
4. Check the exact top-module name and clock-port name in the RTL.

Use simple directory and filenames such as `final_proj` and `top_module.v` to keep the commands easy to follow. In these commands, `~` means your Ubuntu home directory.

**Checkpoint:** Every source dependency is available in the project directory, and the design passes its functional tests.

## 4. Create the configuration file

Create an empty file, then open it in your preferred text editor:

```bash
touch ~/my_designs/final_proj/config.json
```

Enter the following JSON, adapted from the Word document's configuration screenshot:

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

This is an example configuration for the source document's project, not a supplied working design. Replace the module name, source list, and clock settings with your own; remove filenames that are not part of your design and add any required dependencies.

The [LibreLane configuration reference](https://librelane.readthedocs.io/en/stable/reference/configuration.html) explains how design files are resolved. The [flow-variable reference](https://librelane.readthedocs.io/en/stable/reference/common_flow_vars.html) defines the clock settings.

| Setting | Meaning |
| --- | --- |
| `DESIGN_NAME` | Exact name of the RTL top module, including capitalization |
| `VERILOG_FILES` | Source-file list; `dir::` resolves a path relative to this configuration's directory |
| `CLOCK_PORT` | Name of the top-level clock input |
| `CLOCK_PERIOD` | Target period in nanoseconds |

The example's 100 ns period corresponds to 10 MHz. A 100 MHz clock would have a 10 ns period. Choose the target from your design requirements and verify timing; changing a simulation unit does not establish physical timing closure.

JSON requires double-quoted keys and strings, commas between entries, and no trailing comma after the final entry. This example assumes the installed flow's default PDK and library settings. Record those resolved settings with your results; use the assigned configuration if your instructor specifies a different process or library.

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

KLayout should open with the generated layout. If the most recent run failed, `--last-run` may select that incomplete run; resolve the failure before using this shortcut.

Locate the run's `final/` outputs and review its reports. Check timing, physical design rules (DRC), and layout-versus-schematic connectivity (LVS), along with other checks required by the flow. Viewing a layout confirms that you can inspect the geometry; it does not establish that all checks passed.

Record the tool revision, PDK/library, clock period, source revision, run directory, and check results. These details make size and timing comparisons meaningful.

**Checkpoint:** You can show the layout and explain which implementation checks passed or still need attention.

## Troubleshooting

| Symptom | What to check |
| --- | --- |
| `nix-shell` fails with `nixpkgs` not found | Check the Nix installation and the LibreLane revision's setup instructions. Do not assume this error is harmless because a shell prompt appears. |
| `librelane` command not found | Enter the LibreLane Nix environment and rerun the smoke test. |
| Configuration file cannot be parsed | Check commas, double quotes, brackets, and the reported JSON line and column. |
| Top module cannot be found | Compare `DESIGN_NAME` with the module declaration and check that its file is listed. |
| Source path does not exist | Check capitalization, filename extensions, `dir::` paths, and the contents of the project directory. |
| Lint or syntax errors | Open the detailed lint log and fix the reported RTL error, such as a missing semicolon or unsupported construct. |
| Clock-related warnings or timing failures | Verify `CLOCK_PORT`, period units, generated clocks if any, and the actual constrained timing paths. |
| Layout viewer reports missing files | Confirm the selected run completed and produced the required layout outputs. |
| Environment runs out of memory or disk | Check the host and guest resources and design size before changing the configuration or rerunning. |

When asking for help, provide the first actionable error, the relevant configuration, and the recorded tool revision. Reinstalling the whole environment is usually unnecessary for an RTL or configuration error.

## Sources and validation status

Converted from the original course Word document, including its embedded configuration screenshot. Installation and command references were checked against the linked official LibreLane documentation on October 28, 2026. The environment has not been installed or the example run during this conversion; a tested course version and complete RTL example remain to be selected. See the [project review](project-plan.md#local-librelane-instructions) for the migration corrections.

[← Tiny Tapeout guide](tiny-tapeout.md) · [Guide home](index.md)
