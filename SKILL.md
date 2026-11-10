---
name: fpga-to-tiny-tapeout-guide
description: Create and maintain this project's Markdown teaching materials for adapting student Verilog FPGA designs to Tiny Tapeout, verifying them, generating GDSII, and preparing submissions. Use when reviewing the starting references or developing this course guide and its exercises.
---

# FPGA to Tiny Tapeout teaching guide

## Purpose and audience

Help students who already have a Verilog FPGA project adapt its RTL into a Tiny Tapeout digital design, verify its behavior, generate and inspect GDSII, and prepare a specific revision for submission. Explain the ASIC concepts needed for each task without assuming prior physical-design experience.

This repository contains instructional materials. Student chip repositories are separate projects created from the appropriate official Tiny Tapeout template. An FPGA bitstream is not the input to the ASIC flow.

## Instructor voice and course decisions

Write student-facing documentation as directions from the course instructor. Address students as "you" and state concrete course requirements. Use "I" or "we" where it reflects the instructor's intended voice, without inventing commitments or policies.

When a direction depends on an unknown course decision, ask the user what should be written before finalizing that passage. Do not substitute generic phrases such as "assigned by your instructor if it differs," "confirm with your instructor," or "use the course's tested allocation." Gather related questions together, record the answers in the project plan, and use them consistently across the guides. Distinguish student design choices from course policies; project-specific module names and signal mappings can remain adaptable examples.

Keep conversion history, source-document critiques, and unresolved authoring decisions in maintainer notes rather than presenting them as student instructions. Keep material validation limitations visible where students need them.

## Project sources

- Read [docs/project-plan.md](docs/project-plan.md) for the proposed sequence, reference review, and open decisions. Update it as decisions are made.
- Preserve the original files in `starting_references/`. Review both Word documents, including screenshots containing commands or configuration, when migrating their content.
- `TinyTapeout_Documentation.docx` supplies the SKY130 template and submission outline; `LibreLane_Documentation.docx` supplies a local Ubuntu, VirtualBox, Nix, and LibreLane lab.
- `design_sizes.xlsx` contains four example size and cell-count observations. Keep their provenance and unknown measurement conditions visible; they do not establish tile-fit limits or timing feasibility.
- Treat these sources as course context to verify, not automatically correct instructions. Record substantial corrections and unresolved questions in the plan or a focused review note.

## Confirmed course choices

- All students use SKY130 and the official SKY Verilog template. SKY130 is a supported Tiny Tapeout process; do not claim it is the most common without evidence.
- Tile allocation is selected for each project's implementation needs.
- Local LibreLane work is required, using a preinstalled Ubuntu VirtualBox image. Student directions start with the provided VM; installation instructions belong in [docs/vm-preparation.md](docs/vm-preparation.md) for course staff.
- Tiny Tapeout does not prescribe one clock for every project. Explain the documented SKY130 input limit of about 66 MHz separately from the design's timing-limited frequency. Do not retain the source's 100 MHz default. Use project requirements, available clock generation, and timing checks to select and verify a frequency.
- Fabrication submission arrangements are undecided. Student instructions currently end with a submission-ready design; do not invent a shuttle selection, coupon process, purchase requirement, or submission deadline.

## Authoring workflow

1. Use the confirmed course choices above. Establish the remaining template revision, VM/tool versions, representative design, and any later submission arrangements with the user. The references use Basys 3/Vivado as the FPGA context.
2. Check current official Tiny Tapeout and LibreLane documentation and the actual selected template files. Record URLs, verification date, and tested versions or commit IDs. Use named configuration keys and files rather than line-number editing instructions.
3. Write a coherent student path under `docs/`, with small exercises under `exercises/`. Include both the official GitHub Actions workflow and the required local LibreLane lab, and explain the purpose of each.
4. For each lab, give its purpose, prerequisites, files to edit, copyable commands or code, expected result, a meaningful checkpoint, and recovery guidance. Use relative links and descriptive image alt text. Keep commands and configuration as selectable text rather than screenshots alone.
5. Validate examples against the selected template and run the checks relevant to changed RTL or configuration. Distinguish documentation review, simulation, successful GDS generation, physical checks, and confirmed portal submission in status reports. Do not claim a run or submission occurred without evidence.

## Technical rules for this guide

- Inventory the portable RTL and its dependencies. Identify vendor primitives, IP, memories, clocking resources, board pin constraints, and assumptions about power-up state. Explain replacements or limitations explicitly.
- Preserve the official top-level interface. Map each used signal by name and direction. Drive unused output bits deterministically; set bidirectional output enables deliberately. Do not drive input ports merely because they are unused.
- Match reset polarity to the student's core. Invert `rst_n` only for an active-high core reset. Verify asserted reset, release, and subsequent operation; do not rely on FPGA initialization behavior.
- Choose clock frequency and tile allocation from the design requirements, target process, and implementation reports. Keep metadata, simulation units, and implementation constraints consistent. The source's 100 MHz and `1x2` choices are examples, not universal settings.
- Preserve the template's simulation harness unless a tested change requires otherwise. In the reviewed SKY template, the simulation top is `tb`, which instantiates the `tt_um_*` design; update that instance and source lists as appropriate. Replace sample assertions with design-specific checks, including reset and observable function. Waiting for cycles alone is not a functional test.
- Explain synthesis, placement, clock-tree synthesis where applicable, routing, timing, and physical verification at the point students encounter their reports. A layout image or generic local GDS file alone does not prove Tiny Tapeout compatibility.
- Diagnose failures using their first actionable error and the relevant tool version. Do not tell students to ignore unspecified errors, reinstall after every failure, or remove assertions just to get green workflows.
- Teach GDS generation and portal submission as separate milestones. Consult the selected shuttle's current requirements and include submission of the intended revision after successful checks. Keep actual coupon values and account-specific details out of public course materials.

## Publication and completion

Keep Markdown readable directly on GitHub first. GitHub Pages is an optional presentation layer using the same content. Keep course-site publishing instructions separate from the Pages settings required by a student's Tiny Tapeout template.

A release is ready when navigation and links work, code and configuration match the recorded baseline, a representative example has meaningful passing tests and a successful compatible GDS build, and students can identify the intended submission revision. Report outstanding checks explicitly. This skill does not itself authorize publishing, fabrication orders, or purchases; follow the user's task scope.
