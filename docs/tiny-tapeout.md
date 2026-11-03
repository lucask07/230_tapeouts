# Prepare a Tiny Tapeout project

In this project, you will adapt your Verilog FPGA design for SKY130, connect the Tiny Tapeout interface, test its behavior, and generate GDSII. We will prepare the design for submission; fabrication submission arrangements are not yet finalized.

We will all use the [official SKY130 Verilog template](https://github.com/TinyTapeout/ttsky-verilog-template). You will also complete the required [local LibreLane lab](librelane.md) using our preinstalled Ubuntu VirtualBox environment.

## Contents

1. [Identify the reusable RTL](#1-identify-the-rtl-you-will-reuse)
2. [Create your chip repository](#2-create-your-chip-repository)
3. [Connect the interface](#3-connect-your-design-to-the-tiny-tapeout-interface)
4. [Fill in project metadata](#4-fill-in-the-project-metadata)
5. [Write design documentation](#5-write-the-design-documentation)
6. [Adapt simulation tests](#6-adapt-the-simulation-tests)
7. [Run workflows and inspect results](#7-run-the-workflows-and-inspect-the-results)
8. [Prepare for submission](#8-prepare-for-submission)

[Troubleshooting](#troubleshooting)

## Before you begin

Have these items ready:

- A GitHub account and the synthesizable Verilog source for your project.
- The name of your current top module and a list of its ports.
- A description of the required clock, reset polarity, and expected behavior.
- Access to the preinstalled Ubuntu course VM for the local LibreLane lab.

**Checkpoint:** You can explain what your project does and how to test it independently of the FPGA board.

## 1. Identify the RTL you will reuse

1. Open your Vivado project and identify the top module and every module it instantiates. Source files are often in the project's `sources_1` hierarchy; use Vivado's hierarchy view to confirm which files are actually used.
2. Collect those RTL files and any included headers or required data files. Keep simulation-only testbenches separate from synthesizable source.
3. Identify FPGA-specific components such as clock-generation IP, block-memory IP, or device primitives. Replace or adapt them for the ASIC flow before building.
4. Separate the reusable design from board-specific connections. A Basys 3 constraints file describes FPGA package pins; it does not define the Tiny Tapeout pin mapping.
5. Check that sequential logic has a defined reset behavior. Review assumptions about initialized registers and memories using Tiny Tapeout's [FPGA-to-ASIC notes](https://tinytapeout.com/hdl/fpga_vs_asic/).

**Checkpoint:** You have a source-file list, a known top module, and a list of any dependencies that still need adaptation.

## 2. Create your chip repository

1. Open the [SKY130 Verilog template](https://github.com/TinyTapeout/ttsky-verilog-template).
2. Select **Use this template → Create a new repository**.
3. Select your account as the owner, choose a descriptive repository name, and write a short project description.
4. Select **Public**, then create the repository.
5. In your new repository, open **Settings → Pages**. Under **Build and deployment**, set **Source** to **GitHub Actions**, following the template's [Pages setup instructions](https://tinytapeout.com/faq/#my-github-action-is-failing-on-the-pages-part).
6. Open **Actions** and enable workflows if GitHub asks you to do so.

Work in this new chip repository for the remaining steps. This course guide repository is separate from your submission repository.

The Pages setting above supports the template's results viewer. It does not publish this course guide.

**Checkpoint:** Your repository has `src/`, `test/`, `docs/`, `info.yaml`, and the template workflows. Record the template revision used for your project in your project notes.

## 3. Connect your design to the Tiny Tapeout interface

Upload the reusable RTL into `src/`. Open the template's `src/project.v`; this file contains the top-level interface that the chip infrastructure expects. Preserve its port names, widths, and directions.

The current [template wrapper](https://github.com/TinyTapeout/ttsky-verilog-template/blob/main/src/project.v) provides these signals:

| Signal | Direction relative to your design | Purpose |
| --- | --- | --- |
| `ui_in[7:0]` | Input | Dedicated input pins |
| `uo_out[7:0]` | Output | Dedicated output pins |
| `uio_in[7:0]` | Input | Values read from bidirectional pins |
| `uio_out[7:0]` | Output | Values driven onto bidirectional pins |
| `uio_oe[7:0]` | Output | Per-pin drive enable: `1` drives an output; `0` leaves the pin as an input |
| `clk` | Input | Design clock |
| `rst_n` | Input | Active-low reset |
| `ena` | Input | Design enable supplied by the Tiny Tapeout infrastructure |

1. Give the wrapper a unique module name beginning with `tt_um_`, such as `tt_um_yourusername_project`. Rename the file if useful, and use the same module name throughout the project.
2. Instantiate your reusable core inside the wrapper. Connect the core's ports to the Tiny Tapeout signals by name.
3. Write a pin mapping table in your design documentation so the bit assignments are clear.
4. Match the reset polarity. If the core's `reset` input is active high, connect `.reset(!rst_n)`. If its reset is active low, connect `rst_n` directly to that port. Check the core's implementation before choosing.
5. Assign every output bit. Drive unused output bits to zero and configure all bidirectional output-enable bits deliberately. Keep the template's unused-input handling as appropriate; do not drive an input port from inside your wrapper.

For example, if your core produces a four-bit result and uses no bidirectional pins, the output connections could be:

```verilog
// core_result is the four-bit output of your instantiated core.
assign uo_out  = {4'b0000, core_result};
assign uio_out = 8'b00000000;
assign uio_oe  = 8'b00000000;
```

This fragment illustrates output mapping; it is not a complete wrapper. Replace the template's example output assignments rather than adding competing drivers.

**Checkpoint:** Every core input has an intended source, every output bit has one driver, and your pin table matches the wrapper.

## 4. Fill in the project metadata

Open `info.yaml` at the root of your chip repository. Keep its existing structure and schema version. The [official metadata file](https://github.com/TinyTapeout/ttsky-verilog-template/blob/main/info.yaml) explains the available fields.

| Field | What to enter |
| --- | --- |
| `title` | A short project name |
| `author` | Your name or the agreed team name |
| `description` | One sentence explaining the hardware's function |
| `discord` | Your username, if you use it; this field is optional |
| `language` | The hardware description language used |
| `clock_hz` | Intended clock frequency in hertz; use the template's convention for a clockless design |
| `tiles` | The supported allocation selected for your project's implementation needs |
| `top_module` | The exact `tt_um_...` wrapper module name |
| `source_files` | Each required RTL source filename, relative to `src/` |
| `pinout` | Descriptive labels for the pins you use; leave unused labels blank and preserve the listed pins |

For example, a two-file project might use this subsection:

```yaml
  top_module: "tt_um_yourusername_project"
  source_files:
    - "tt_um_yourusername_project.v"
    - "core.v"
```

Replace the names with your actual files. Match the indentation of the surrounding `project` mapping. Keep the source list consistent with `test/Makefile`.

### Choose a clock and tile allocation

Choose the operating clock from your project's functional requirements and verify it against implementation timing. We will not automatically carry over the Basys 3 board's 100 MHz clock.

Tiny Tapeout's [clock specification](https://tinytapeout.com/specs/clock/) describes an external clock input and an approximately 66 MHz SKY130 input-pad rating. Its [GPIO guidance](https://tinytapeout.com/specs/gpio/) distinguishes that limit from the maximum frequency of the logic inside your design. The pad rating is not a guarantee that your design meets timing at that frequency.

1. Identify the frequency needed by your design, including any clock-dependent counters, display timing, or serial interfaces.
2. Select a target within the documented SKY130 input limits and supported by your clock source. Do not use 100 MHz as the default target for this course.
3. Enter the intended operating frequency in `clock_hz`. Check the actual implementation constraints separately; do not assume that metadata alone configures every timing constraint.
4. Use the corresponding clock period in your simulation and local LibreLane configuration. Verify timing for the intended frequency and relevant process, voltage, and temperature conditions.
5. If timing fails, revise the design or lower its operating frequency and update any logic that depends on real-time intervals. Repeat the checks at the revised target.

The clock-period conversion is:

```text
period in nanoseconds = 1,000,000,000 / frequency in hertz
```

For example, 10 MHz corresponds to 100 ns, and 50 MHz corresponds to 20 ns. These are conversion examples, not required operating frequencies. Preserve the template's supported timing-constraint mechanism; the configuration used for the local LibreLane lab is a separate file.

Select a supported tile allocation based on your project's area and routing needs. Start with the smallest allocation that appears suitable, then check utilization, routing, and timing results. Increase the allocation if the design cannot fit and route successfully. Record why you selected it; we will not use a fixed `1x2` allocation for every project.

**Checkpoint:** Module names, filenames, clock requirements, tile allocation, and pin labels agree with the design.

## 5. Write the design documentation

Open `docs/info.md` **in your chip repository** and complete its existing sections:

- **How it works:** Explain the design's purpose, main modules, and input/output behavior. Include the pin map and relevant clock and reset assumptions.
- **How to test:** Give a human operator a sequence of input changes and expected outputs. Explain how to reset the design, start it, and recognize correct operation.
- **External hardware:** List required equipment, switches, displays, or Pmods and explain their connections.

Use signal names and pin numbers that match your wrapper. Replace references to FPGA-board buttons or LEDs with the actual external connections needed to use the manufactured chip.

**Checkpoint:** A classmate could describe how to operate your chip using the documentation and pin map.

## 6. Adapt the simulation tests

The template uses a Verilog harness in `test/tb.v` and a Python test in `test/test.py`. The harness instantiates your design; cocotb drives its signals and checks results. Follow the [template test instructions](https://github.com/TinyTapeout/ttsky-verilog-template/blob/main/test/README.md) for your repository version.

1. In `test/Makefile`, set `PROJECT_SOURCES` to the RTL filenames in `src/`, separated by spaces. For the two-file example:

   ```makefile
   PROJECT_SOURCES = tt_um_yourusername_project.v core.v
   ```

2. Keep `TOPLEVEL = tb` when using the template harness. In `test/tb.v`, replace the example design's module name with your wrapper module name. Preserve the harness connections and gate-level power-port conditionals.
3. In `test/test.py`, use the simulation period selected for your design. For example, a 10 MHz clock has a 100 ns period, written as `Clock(dut.clk, 100, unit="ns")` in the current template's cocotb syntax.
4. Set `ena` and all testbench-driven inputs to known values. Assert `rst_n = 0`, hold reset for the duration required by your design, and release it with `rst_n = 1`.
5. Replace the template's sample stimulus and expected sum with tests for your own hardware. Check reset behavior, representative operations, and boundary cases. If a result takes multiple cycles, wait for the required latency and sample after the signals settle.
6. Add assertions that compare actual outputs with expected outputs. Merely waiting 100 cycles does not establish correct behavior.

**Checkpoint:** Your test fails when the observed behavior is wrong and passes when the expected behavior occurs. Include a reset during operation if your design requires that behavior.

## 7. Run the workflows and inspect the results

Save and commit your edits. If editing a local clone, push the commit to GitHub. Open **Actions** in your chip repository and select the runs for that commit.

Workflow names and job structure can change. The current [SKY GDS workflow](https://github.com/TinyTapeout/ttsky-verilog-template/blob/main/.github/workflows/gds.yaml) includes GDS generation, precheck, gate-level testing, and a viewer job.

| Check | What to look for |
| --- | --- |
| RTL tests | Your behavioral assertions pass. |
| GDS generation | The implementation flow completes and produces layout artifacts. |
| Precheck and physical checks | The selected flow's required checks pass; investigate reported violations. |
| Gate-level tests | The implemented netlist passes the applicable behavioral tests. |
| Documentation | The generated design documentation builds and describes your project correctly. |
| FPGA workflow | This checks a separate FPGA build; it does not replace ASIC implementation and verification. |

A queued or running job has not passed yet. If a run fails, open the failed job, find the first actionable error, fix the corresponding file, and commit the correction. Use **Run workflow** only when that workflow provides the manual-run option; otherwise trigger it according to its configuration.

After implementation succeeds:

1. Read the run summary and the available area, utilization, and timing reports.
2. Confirm that the reported clock constraints match your intended operating conditions. Resolve reported violations and bring questions about the reports to me. The presence of a GDS file alone is not sufficient evidence of a successful implementation.
3. Open the generated viewer to inspect the layout. Download the run's artifacts if you need the GDSII or detailed reports; artifact names and paths depend on the flow version.
4. Record the commit and workflow run URL for your successful build.

**Checkpoint:** You can connect the tested source revision to its generated layout and explain the status of its required checks.

## 8. Prepare for submission

Stop at a submission-ready project for now. Our fabrication submission arrangements have not yet been finalized; do not place an order or submit a fabrication revision as part of these steps.

Prepare these items:

- Your public chip repository URL and intended commit.
- Passing functional tests, implementation checks, and generated documentation for that commit.
- The GDS workflow run URL, layout artifacts, and required reports.
- Your chosen tile allocation, operating frequency, and pin map.
- A reproducible procedure for testing the manufactured design.

The [official submission guide](https://tinytapeout.com/guides/advanced-workshop/submit-your-design/) explains how the portal submits a specific revision. Read it to understand the later process; a successful GitHub build does not itself submit the design for fabrication.

**Checkpoint:** Your project is ready for review and you can identify the exact source revision associated with its verified layout.

## Troubleshooting

| Symptom | First checks |
| --- | --- |
| Module not found | Compare the wrapper name, `top_module`, the instance in `test/tb.v`, and source lists. Check spelling and case. |
| Design stays reset or starts unpredictably | Check the core's reset polarity, wrapper connection, test stimulus, and reset coverage of state registers. |
| Multiple drivers or undriven outputs | Remove the template's replaced assignments and check each output bit and bidirectional enable. |
| RTL test passes without exercising the design | Check that the test drives meaningful inputs and contains design-specific assertions. |
| GDS viewer fails to deploy | Verify the chip repository's Pages source and inspect the viewer job's permissions or deployment errors. |
| Layout or timing fails | Read the failing implementation report; review area, clock requirements, routing, and unsupported RTL dependencies. |
| Workflow has not started | Check that Actions is enabled, the changes reached GitHub, and the workflow supports the event you used. |

## Guide status

The instructions have been reviewed against the linked official documentation. A complete course example has not yet been run through this guide.

[← Guide home](index.md) · [Required local LibreLane lab →](librelane.md)
