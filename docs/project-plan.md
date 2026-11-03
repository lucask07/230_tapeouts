# Plan for the FPGA to Tiny Tapeout student guide

Create a Markdown lab sequence that takes a student's existing Verilog FPGA design through ASIC adaptation, verification, GDSII generation, and Tiny Tapeout submission preparation. Publish the guide in this GitHub repository, with GitHub Pages as an optional later reading interface.

## Reference review

Reviewed on October 28, 2026: the text of both Word documents, the embedded LibreLane screenshots, and all populated cells in the workbook. The sources contain a useful practical outline, but converting their wording directly would preserve technical mistakes and assumptions that need validation. No student RTL, tested example repository, or implementation logs are supplied.

### Tiny Tapeout instructions

Source: [TinyTapeout_Documentation.docx](../starting_references/TinyTapeout_Documentation.docx).

Retain the sequence of creating a repository from the SKY Verilog template, adding RTL, creating an interface wrapper, editing project metadata, documenting behavior, running workflows, and using the submission portal.

| Existing instruction or gap | Proposed treatment |
| --- | --- |
| Upload all Vivado `.v` files | Identify the synthesizable design hierarchy and dependencies first; distinguish RTL from testbenches, generated files, vendor IP, and board constraints. |
| Invert the reset for every project | Explain active-low Tiny Tapeout reset and invert only when the core expects an active-high reset. Test both assertion and release. |
| Tie unused inputs and outputs to zero | Drive unused outputs and configure bidirectional output enables. Do not assign to input ports. Match widths and directions to the wrapper interface. |
| Set `CLOCK_PERIOD` to 10 ns to match Basys 3 | Establish the intended ASIC operating clock and check timing. Synchronize metadata, simulation, and implementation constraints through the selected template's supported mechanism. Do not assume a particular `config.json` exists. |
| Change every design to `1x2` tiles | Choose allocation using the selected shuttle's geometry, budget, and actual implementation results. |
| Change simulation top from `tb` to the wrapper | The current SKY template retains `TOPLEVEL = tb`; its test instructions update the design instance in `test/tb.v`. Preserve and explain this harness. |
| Wait 100 cycles and delete the sample assertion | Replace the template test with design-specific assertions. Include reset, representative inputs, outputs, and boundary behavior. Use appropriate simulation durations for the design. |
| Edit files using fixed line numbers | Refer to filenames, keys, variables, and module instances. Record the template revision used for examples. |
| All workflow categories are treated alike | Explain functional tests, GDS generation, documentation, and optional FPGA validation separately. Check actual submission requirements for the selected shuttle. |
| Submission ends with the general portal steps | Include selecting and submitting the intended revision and checking its portal status. A passing build alone does not complete submission. |

These corrections are supported by the official [wrapper](https://github.com/TinyTapeout/ttsky-verilog-template/blob/main/src/project.v), [test instructions](https://github.com/TinyTapeout/ttsky-verilog-template/blob/main/test/README.md), [Makefile](https://github.com/TinyTapeout/ttsky-verilog-template/blob/main/test/Makefile), [project metadata](https://github.com/TinyTapeout/ttsky-verilog-template/blob/main/info.yaml), [FPGA-to-ASIC notes](https://tinytapeout.com/hdl/fpga_vs_asic/), and [submission guide](https://tinytapeout.com/guides/advanced-workshop/submit-your-design/), checked October 28, 2026. These moving links must be paired with a recorded template commit when the example is implemented.

### Local LibreLane instructions

Source: [LibreLane_Documentation.docx](../starting_references/LibreLane_Documentation.docx).

Retain the local-flow teaching objective: install the environment, collect RTL, write a configuration, run implementation, diagnose failures, and inspect the layout in KLayout.

- Reassess the fixed VM recommendation of 25–31 GB RAM and six CPUs against available student machines. Document tested host architecture, guest OS, disk space, and resource needs rather than presenting one machine's allocation as a requirement.
- Replace the advice to ignore Nix errors with an installation smoke test and diagnosis of the actual failure. A shell prompt alone is insufficient evidence of a working toolchain.
- Verify installation commands against official documentation and pin a tested LibreLane version. Repair spaces introduced into shell paths and present the full configuration as a fenced code block; it currently appears only in a screenshot.
- Explain `DESIGN_NAME`, `VERILOG_FILES`, `CLOCK_PORT`, and `CLOCK_PERIOD`, including units. The screenshot uses a 100 ns period, whereas the Tiny Tapeout document calls for 10 ns; these examples need explicit context and consistent requirements.
- Teach targeted recovery from configuration and RTL errors. Verify whether the environment is still active before asking students to reopen it.
- Explain that hardening arbitrary RTL locally does not automatically create a shuttle-compatible submission. Use the Tiny Tapeout wrapper and supported hardening procedure when claiming submission compatibility.

Use the official [Nix installation guide](https://librelane.readthedocs.io/en/latest/installation/nix_installation/index.html), [Linux installation and smoke test](https://librelane.readthedocs.io/en/stable/installation/nix_installation/installation_linux.html), and [configuration reference](https://librelane.readthedocs.io/en/latest/reference/configuration.html) during implementation. Installation has not been executed as part of this review.

### Design size workbook

Source: [design_sizes.xlsx](../starting_references/design_sizes.xlsx), `Sheet1!A1:C5`.

The workbook contains four examples: `pm32`, `tiny-gpu`, `counter state machine`, and `final project`, with dimensions in micrometers and counts expressed as cells under a column labeled `Gates`. It provides useful material for an area discussion, but does not identify the PDK, library, clock constraint, tool version, utilization, measurement stage, or source RTL.

Use it as historical example data until those conditions are established. Distinguish cells from equivalent gates, and core area from die or tile area. Do not derive a universal gate budget or a guaranteed tile allocation from these observations.

## Recommended teaching approach

Use the official SKY130 Tiny Tapeout template and Actions for submission-compatible builds. Local LibreLane work is also required, using a preinstalled Ubuntu VirtualBox image. Students start with the supplied environment rather than installing the tools themselves. Staff preparation instructions are retained in [vm-preparation.md](vm-preparation.md).

Begin with one small sequential example that has explicit reset and easily checked outputs. Carry that example through every chapter, then have students repeat the process with their own FPGA project. Keep this instructional repository separate from each student's chip submission repository.

## Proposed student guide structure

The first conversion is available as [Prepare a Tiny Tapeout project](tiny-tapeout.md) and [Run LibreLane locally](librelane.md), linked from the [guide home](index.md). These retain the two source documents' workflows while clarifying and correcting the steps. The finer chapter split below remains a possible later organization after the worked example and student pilot.

| Planned page | Student outcome and checkpoint |
| --- | --- |
| `docs/index.md` | Understand the FPGA-to-ASIC path, deliverables, prerequisites, and where to start. |
| `docs/01-project-readiness.md` | Inventory portable RTL, vendor dependencies, resets, clocks, memory, and I/O; complete a readiness checklist. |
| `docs/02-repository-setup.md` | Create a chip repository from the selected template; record baseline versions and understand its files and workflows. |
| `docs/03-interface-and-constraints.md` | Build and explain the wrapper, pin map, reset adaptation, clock target, source list, and tile choice. |
| `docs/04-functional-verification.md` | Run meaningful tests, inspect waveforms, and demonstrate reset and required behavior. |
| `docs/05-gds-and-reports.md` | Generate GDSII through Actions; inspect layout, timing, area, and required physical/precheck results for the same commit. |
| `docs/06-documentation-and-submission.md` | Complete the design datasheet and hardware test procedure; submit and verify the intended revision when authorized. |
| `docs/07-local-librelane.md` | Start and smoke-test the preinstalled course VM, run a documented example, and inspect layout in KLayout. |
| `docs/troubleshooting.md` | Diagnose common source, wrapper, simulation, installation, configuration, and implementation failures. |
| `exercises/` | Practice with a worked example and adapt a personal project; use small, runnable assets with expected behavior. |

Each chapter should have prerequisites, numbered tasks, editable examples, expected results, troubleshooting links, and a checkpoint. Use screenshots for orientation and layout interpretation; keep commands, RTL, and configuration in text. Add previous/next navigation and keep terminology consistent.

## Implementation phases

1. **Establish the baseline.** Use SKY130 and required local LibreLane in the preinstalled Ubuntu VirtualBox image. Select a template commit, VM/tool versions, supported hosts, and representative design. Capture remaining submission decisions when available. Exit: the example and toolchain are reproducible in principle and the remaining unknowns are explicit.
2. **Build the verified example.** Adapt portable RTL, implement the wrapper and metadata, and write behavior-based tests. Run the supported flow and capture a successful GDS build plus timing and physical-check evidence. Exit: students have a tested reference to compare against. Record any gate-level simulation performed and its limitations.
3. **Rewrite the guide.** Convert both Word documents into the chapter sequence above, applying the technical corrections. Add a glossary, pin mapping table, diagrams where useful, report interpretation, and instructor checkpoints. Exit: every instruction has an expected result and all sample values have context.
4. **Validate the learning path.** Follow the guide from a fresh student repository, test its copyable commands, validate links and Markdown, and pilot it with a student or TA. Exit: observed failures have actionable troubleshooting and the pilot can reach a submission-ready revision.
5. **Publish and maintain.** Publish the reviewed Markdown to the existing GitHub remote. Optionally enable GitHub Pages using the same source content; validate navigation in both views. Choose a reuse license before public release and check screenshots for personal information. Tag a course release and record a pre-semester review of external links, templates, and shuttle rules. Exit: a verified public URL and a named course baseline.

The existing remote is [lucask07/230_tapeouts](https://github.com/lucask07/230_tapeouts). No push, Pages deployment, student submission, or fabrication order has been performed in this planning pass. GitHub supports a Pages presentation layer; see its [Pages documentation](https://docs.github.com/en/pages). Course-site hosting settings and student Tiny Tapeout results-page settings need separate instructions.

## Confirmed course decisions

Recorded October 28, 2026:

- Use SKY130 for every student project. Tiny Tapeout provides a current official SKY Verilog template. Its homepage also lists IHP and GF templates; this review establishes that SKY130 is supported, not that it is statistically the most common process.
- Select tile allocations according to each project's area and routing needs rather than imposing `1x2`.
- Require LibreLane, preinstalled in an Ubuntu VirtualBox image. Move image installation steps out of student directions and preserve them as staff preparation instructions.
- Choose operating clocks per project using documented interface limits and timing results. The official [clock specification](https://tinytapeout.com/specs/clock/) describes an approximately 66 MHz SKY130 input-pad limit, and the [GPIO specification](https://tinytapeout.com/specs/gpio/) distinguishes pad limits from logic timing. This is not a universal operating frequency or a guarantee of timing closure. Remove the prior 100 MHz example as a default; 10 MHz/100 ns remains an illustrative conversion, not an imposed course frequency.
- Submission arrangements are undecided. Preserve the original submission outline below as maintainer context; student directions stop at a submission-ready project.

### Submission outline for later authoring

Once arrangements are confirmed, use the [official submission guide](https://tinytapeout.com/guides/advanced-workshop/submit-your-design/) to document portal login, repository selection, the specific compatible SKY shuttle, coupon or payment handling if applicable, and submission and verification of the intended revision. New GitHub commits require a new portal revision to update the submitted design. Do not publish an actionable course submission sequence until these decisions are supplied.

## Decisions for the next work session

- Confirm the Basys 3/Vivado reference context and select a template commit.
- Finalize the target SKY shuttle, submission timing, and coupon/payment arrangements when ready.
- Supply or select a small reference RTL design and identify which existing student project will serve as the migration example.
- Select the Ubuntu/LibreLane versions, host hardware requirements, image delivery method, VM login process, and tested checkout path. Build and validate the image; this documentation pass has not done so.
- Set course deliverables and assessment criteria, public repository licensing, and whether a Pages reading interface is wanted.

## Current status

Completed: source content review, comparison with the current official SKY template, initial correction list, project skill, implementation proposal, and initial Markdown conversion of both Word documents with student navigation and official links.

Remaining: baseline decisions, RTL examples, complete executable validation of the converted guides, student pilot, optional chapter reorganization, and publication. The Markdown conversion does not establish that the installation or GDS flow has been run successfully.
