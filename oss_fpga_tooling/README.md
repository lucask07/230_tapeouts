# Set up the Tiny Tapeout FPGA tools

Run this setup inside the Ubuntu VirtualBox VM as the regular Ubuntu user who will build designs and connect to the board. You need internet access, sudo privileges, and several gigabytes of free disk space for the download, extracted tools, and Python packages.

```bash
bash setup_tinytapeout_fpga.sh
```

The script installs OSS CAD Suite, Tiny Tapeout support tools, and their Python requirements under `~/tiny-tapeout-fpga`. It adds the current Ubuntu user to `dialout` for serial access. It selects the Linux x64 or ARM64 archive based on the guest architecture.

The default OSS CAD Suite release is **2026-11-19**, matching the supplied shell history. Its archive is checked against the SHA256 published with that release. The first installation clones the current Tiny Tapeout support tools and records the exact commit and Python package versions in `installed-versions.txt`. Rerunning reuses the existing suite and clean tools checkout and repeats the dependency and command checks. An incomplete download or clone can be retried. An unrecognized existing destination or a modified tools checkout stops setup with a diagnostic.

Use a different destination if needed. Choose a path without spaces.

```bash
bash setup_tinytapeout_fpga.sh --prefix "$HOME/teaching/tiny-tapeout-fpga"
```

Run setup from a fresh Terminal outside the LibreLane, virtualenv, and OSS CAD environments. Python dependencies are installed using `python3 -m pip install -r ...` after activating the suite's bundled Python. The script verifies that Python belongs to the suite before installing packages.

## Activate the tools

After setup, log out of the Ubuntu desktop completely and log back in, or reboot the VM. This activates the new `dialout` membership.

In each Terminal used for this lab, run the following. Adjust the path if you selected another installation destination.

```bash
source ~/tiny-tapeout-fpga/activate.sh
tt-fpga --help
```

`tt-fpga` launches the installed `tt_fpga.py` using the suite environment. It accepts the same arguments as the upstream script and keeps your current project directory. Use a separate Terminal for LibreLane.

## Enable USB passthrough on the host

Configure these settings in VirtualBox on the physical host computer.

1. Connect the MicroPython demoboard using a USB data cable.
2. Shut down the VM. Open its **Settings → USB** and enable a USB controller supported by your VirtualBox installation. If VirtualBox requests an Extension Pack for the selected controller, install the matching version on the host.
3. Optionally add a USB filter for this specific board so that VirtualBox reconnects it automatically. Select the board from the device list.
4. Start Ubuntu. In the running VM's **Devices → USB** menu, select the board and check that it is attached.
5. Inside Ubuntu, activate the tools and inspect USB and serial devices.

   ```bash
   lsusb
   python3 -m serial.tools.list_ports -v
   id -nG
   ```

Identify the board's serial port, commonly `/dev/ttyACM0`. Check its ownership and permissions.

```bash
ls -l /dev/ttyACM0
```

Use the port reported for your board in the commands below. The logged-in user should have `dialout` in the output of `id -nG`. If the board is absent from `lsusb`, check VirtualBox attachment and the cable. If it is present but serial access is denied, check guest group membership and complete the logout/login step. Close any serial monitor connected to the board before uploading.

On a Linux host, VirtualBox may also require the host user to belong to `vboxusers`. Configure that on the host and log out and back in there. Guest `dialout` membership and host `vboxusers` membership apply to different systems. VirtualBox documents USB capture and filters in its VM settings guide. [VirtualBox USB settings](https://docs.oracle.com/en/virtualization/virtualbox/7.2/user/working-with-vms.html)

## Build and upload your project

Open a Terminal in your Tiny Tapeout design repository and activate the tools. Check that `info.yaml` lists your wrapper top module and every required RTL source file.

```bash
source ~/tiny-tapeout-fpga/activate.sh
tt-fpga harden --help
tt-fpga harden
```

Choose `--breakout-target classic` for the TT04 breakout or `--breakout-target fabricfox` for the TT ETR breakout according to your hardware. Inspect the help output to confirm the installed version's default before building. The generated FPGA bitstream is written under the project's `build/` directory. [Tiny Tapeout FPGA breakout guide](https://tinytapeout.com/guides/fpga-breakout/)

After building, upload using the board's serial port.

```bash
tt-fpga configure --port /dev/ttyACM0 --upload
```

The project name comes from `info.yaml`. If specifying a name explicitly, match the built bitstream's name, such as `tt_um_top_module`. A clock and startup default can also be set deliberately for the project. This example uses the 2 MHz clock from the supplied history.

```bash
tt-fpga configure --port /dev/ttyACM0 --upload \
    --name tt_um_top_module --set-default --clockrate 2000000
```

The MicroPython board needs the Tiny Tapeout firmware and FPGA breakout support described in the official guide. The installer prepares the Ubuntu tools. Board firmware installation, FPGA builds, and uploads are separate steps you run with the intended hardware and project.

## Installation record and validation

Sources were reviewed on November 21, 2026. The supplied history is retained alongside the installer. The release date follows that history, and the initial Tiny Tapeout checkout follows the upstream default branch. Use the generated revision record when preparing the class VM image.

The installer has been checked with Bash syntax validation and a mocked installation workflow. A complete Ubuntu installation, FPGA build, and physical USB upload still need to be validated on the course VM and board.

- [Tiny Tapeout FPGA breakout setup](https://tinytapeout.com/guides/fpga-breakout/)
- [OSS CAD Suite installation and bundled Python](https://github.com/YosysHQ/oss-cad-suite-build#installation)
- [OSS CAD Suite 2026-11-19 release and checksums](https://github.com/YosysHQ/oss-cad-suite-build/releases/expanded_assets/2026-11-19)
- [Tiny Tapeout Python requirements](https://github.com/TinyTapeout/tt-support-tools/blob/main/requirements.txt)
