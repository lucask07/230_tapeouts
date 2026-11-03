# Prepare the course VirtualBox image

Maintainer instructions retained from the initial Word-to-Markdown conversion. The image has not been built or validated as part of this documentation work. The Ubuntu version, LibreLane revision, image delivery method, login details, and host requirements remain to be selected.

## 1. Prepare Ubuntu

Prepare the Ubuntu VirtualBox image before distributing it to students. This page is for course staff; students start with the preinstalled image described in the [local lab](librelane.md).

1. Install [Oracle VirtualBox](https://www.virtualbox.org/wiki/Downloads) if your computer supports the course's VM configuration.
2. Download the Ubuntu ISO selected for the course image from [Ubuntu releases](https://releases.ubuntu.com/). Match the guest architecture to your supported host setup; an Intel/AMD image is not a universal choice for every computer.
3. In VirtualBox, select **New** or **Create a new virtual machine**, depending on your version.
4. Enter a VM name, choose a storage location, and select the ISO image.
5. Configure your Ubuntu username and password if using unattended installation. Otherwise, enter them during the Ubuntu installer.
6. Allocate CPU, memory, and disk resources that fit your host while leaving capacity for the host operating system. Record the tested host and guest allocations with the image release.
7. Start the VM and complete Ubuntu setup. Open **Terminal** after logging in.

The [official LibreLane Linux requirements](https://librelane.readthedocs.io/en/stable/installation/nix_installation/installation_linux.html) list 8 GiB of RAM as a minimum and 16 GiB as recommended, with a quad-core CPU as the minimum CPU guidance. A VM must fit within the host's resources, and large designs can require more. Allow storage for Ubuntu, tools, the process design kit, and multiple implementation runs.

The original document's 25–31 GB memory allocation and six CPUs described one setup; they are not universal requirements. Document a supported host configuration before distributing the image.

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

Record the commit printed by `git rev-parse HEAD`. Select and check out a tested release or commit before entering `nix-shell`, then record it with the image release. If `~/librelane` already exists, inspect the existing checkout instead of cloning over it.

The first environment setup downloads dependencies and may take some time. When it finishes, run:

```bash
librelane --smoke-test
```

**Checkpoint:** The smoke test completes successfully. A changed shell prompt alone does not prove the installation works. Stop and diagnose installation errors before running your own design.

## Before distributing the image

Verify that the installed flow uses SKY130 (`sky130A`), record the standard-cell library and tool revisions, and test the smoke test and KLayout GUI from a fresh VM start. Confirm that `~/librelane` is the tool checkout used by the student commands. Document how students receive and open the image, without placing reusable private credentials in this repository.

[Student lab](librelane.md) · [Project plan](project-plan.md)
