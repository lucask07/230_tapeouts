#!/usr/bin/env bash
# Run as the student's regular user inside an Ubuntu VirtualBox guest.
set -euo pipefail

usage() {
    cat <<'EOF'
Usage: bash setup_tinytapeout_fpga.sh [--prefix DIRECTORY] [--help]

Install OSS CAD Suite 2026-11-19, Tiny Tapeout support tools, and their
Python dependencies. Add the current Ubuntu user to the dialout group.

The default directory is ~/tiny-tapeout-fpga. Existing installations are
reused. Run as your regular user with sudo access, without sourcing an
OSS CAD Suite, Python virtual environment, or LibreLane environment first.

USB passthrough must also be enabled in VirtualBox on the host computer.
EOF
}

die() {
    printf 'ERROR: %s\n' "$*" >&2
    exit 1
}

check_guest() {
    [[ $(uname -s) == Linux && -r /etc/os-release ]] ||
        die 'Run this script inside the Ubuntu VM.'
    # shellcheck source=/dev/null
    source /etc/os-release
    [[ ${ID:-} == ubuntu ]] || die 'This installer supports Ubuntu guests.'
    (( EUID != 0 )) || die 'Run as your regular Ubuntu user, without sudo. The script invokes sudo when needed.'
    [[ -z ${VIRTUAL_ENV:-} && -z ${CONDA_PREFIX:-} && -z ${IN_NIX_SHELL:-} && -z ${OSS_CAD_SUITE:-} ]] ||
        die 'Open a fresh Ubuntu Terminal outside your existing tool environments.'
    command -v sudo >/dev/null || die 'Install sudo and grant this Ubuntu user sudo access first.'
    command -v flock >/dev/null || die 'The Ubuntu util-linux package must provide flock.'
}

install_suite() {
    if [[ -e $suite_dir ]]; then
        [[ -f $suite_dir/.course-release && $(cat "$suite_dir/.course-release") == "$release/$architecture" ]] ||
            die "An unrecognized suite exists at $suite_dir. Choose another --prefix."
        [[ -f $suite_dir/environment && -x $suite_dir/bin/yosys ]] ||
            die "The suite at $suite_dir is incomplete. Choose another --prefix."
        printf 'Reusing OSS CAD Suite at %s\n' "$suite_dir"
        return
    fi

    local asset="oss-cad-suite-linux-${architecture}-20261119.tgz"
    local download_url="https://github.com/YosysHQ/oss-cad-suite-build/releases/download/${release}/${asset}"
    suite_stage=$(mktemp -d "$install_dir/.suite-stage.XXXXXX")
    printf 'Downloading %s\n' "$asset"
    curl --fail --location --retry 3 --connect-timeout 30 \
        --output "$suite_stage/$asset" "$download_url"
    printf '%s  %s\n' "$suite_sha256" "$suite_stage/$asset" | sha256sum --check -
    tar -xzf "$suite_stage/$asset" -C "$suite_stage"
    [[ -f $suite_stage/oss-cad-suite/environment ]] || die 'The archive is missing the suite environment.'
    printf '%s\n' "$release/$architecture" > "$suite_stage/oss-cad-suite/.course-release"
    mv "$suite_stage/oss-cad-suite" "$suite_dir"
}

install_tt_tools() {
    if [[ -e $tt_dir ]]; then
        [[ -d $tt_dir/.git ]] || die "An unrelated directory exists at $tt_dir. Choose another --prefix."
        [[ $(git -C "$tt_dir" remote get-url origin) == "$tt_repository" ]] ||
            die "The existing checkout at $tt_dir has a different origin. Choose another --prefix."
        [[ -z $(git -C "$tt_dir" status --porcelain) ]] ||
            die "The tools checkout at $tt_dir has local changes. Preserve them before rerunning."
        printf 'Reusing Tiny Tapeout checkout at %s\n' "$tt_dir"
    else
        tt_stage=$(mktemp -d "$install_dir/.tt-stage.XXXXXX")
        git clone --recurse-submodules "$tt_repository" "$tt_stage/tt"
        mv "$tt_stage/tt" "$tt_dir"
    fi
    [[ -f $tt_dir/tt_fpga.py && -f $tt_dir/requirements.txt ]] ||
        die 'The Tiny Tapeout checkout is missing tt_fpga.py or requirements.txt.'
    git -C "$tt_dir" submodule update --init --recursive
}

cleanup() {
    # Delete only the temporary staging directories created by this invocation.
    [[ -z ${suite_stage:-} ]] || rm -rf -- "$suite_stage"
    [[ -z ${tt_stage:-} ]] || rm -rf -- "$tt_stage"
}

main() {
    local prefix="$HOME/tiny-tapeout-fpga"
    while (( $# )); do
        case "$1" in
            --prefix)
                (( $# >= 2 )) || die '--prefix needs a directory.'
                [[ -n $2 && $2 != -* ]] || die '--prefix needs a directory.'
                prefix=$2
                shift 2
                ;;
            --help|-h) usage; return ;;
            *) die "Unknown option $1. Use --help." ;;
        esac
    done

    check_guest
    local release=2026-11-19 architecture suite_sha256
    case $(uname -m) in
        x86_64)
            architecture=x64
            suite_sha256=e451bfd6c22c58aea98c812feff3262ddbf06e6f0c4008c796d0ef5d082036ff
            ;;
        aarch64|arm64)
            architecture=arm64
            suite_sha256=5e9fead6ba31e28df81d71f6c8eccbc7f7e3cc9f100d3a7c39222471d238bce6
            ;;
        *) die 'Supported Ubuntu guest architectures are x86_64 and aarch64.' ;;
    esac

    mkdir -p "$prefix"
    local install_dir
    install_dir=$(cd "$prefix" && pwd -P)
    [[ $install_dir != *[[:space:]]* ]] || die 'Choose an installation directory without whitespace.'
    exec 9>"$install_dir/.setup.lock"
    flock --nonblock 9 || die 'Another setup is using this installation directory.'

    local suite_dir="$install_dir/oss-cad-suite"
    local tt_dir="$install_dir/tt"
    local tt_repository=https://github.com/TinyTapeout/tt-support-tools.git
    local ubuntu_user
    ubuntu_user=$(id -un)
    # Globals let the EXIT trap clean staging files even after main returns.
    suite_stage=''
    tt_stage=''
    trap cleanup EXIT
    trap 'printf "Setup failed near line %s. Correct the reported error and rerun.\n" "$LINENO" >&2' ERR

    sudo -v
    sudo apt-get update
    sudo apt-get install -y ca-certificates curl git python3 python3-pip \
        tar gzip usbutils libcairo2 libglib2.0-0 libgl1 libusb-1.0-0

    install_suite
    install_tt_tools

    # The suite's Python avoids Ubuntu's externally managed system Python and
    # uses the interpreter expected by the guide's activated OSS CAD environment.
    set +u
    # shellcheck source=/dev/null
    source "$suite_dir/environment"
    set -u
    export PYTHONNOUSERSITE=1
    python3 - "$suite_dir" <<'PY'
import pathlib
import sys

suite = pathlib.Path(sys.argv[1]).resolve()
if not pathlib.Path(sys.prefix).resolve().is_relative_to(suite):
    raise SystemExit("The active python3 does not belong to OSS CAD Suite. Open a fresh Terminal and rerun.")
PY
    python3 -m pip --version
    python3 -m pip install -r "$tt_dir/requirements.txt"
    python3 -m pip check

    # Activation is explicit so that other course tool environments can be used
    # in their own terminals. Do not change the user's shell startup files.
    mkdir -p "$install_dir/bin"
    {
        printf '# Source this file in Bash to activate the Tiny Tapeout FPGA tools.\n'
        printf 'export TT_FPGA_ROOT=%q\n' "$install_dir"
        cat <<'ACTIVATE'
_tt_restore_nounset=false
case $- in *u*) _tt_restore_nounset=true ;; esac
set +u
source "$TT_FPGA_ROOT/oss-cad-suite/environment"
if $_tt_restore_nounset; then set -u; fi
unset _tt_restore_nounset
export PYTHONNOUSERSITE=1
export PATH="$TT_FPGA_ROOT/bin:$PATH"
ACTIVATE
    } > "$install_dir/activate.sh"

    cat > "$install_dir/bin/tt-fpga" <<'WRAPPER'
#!/usr/bin/env bash
set -euo pipefail
tool_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)
source "$tool_root/activate.sh"
exec python3 "$TT_FPGA_ROOT/tt/tt_fpga.py" "$@"
WRAPPER
    chmod +x "$install_dir/bin/tt-fpga"

    printf '\nChecking installed commands...\n'
    yosys -V
    nextpnr-ice40 --version
    command -v icepack
    "$install_dir/bin/tt-fpga" --help
    "$install_dir/bin/tt-fpga" harden --help
    "$install_dir/bin/tt-fpga" configure --help
    python3 -m mpremote --help >/dev/null

    if ! id -nG "$ubuntu_user" | tr ' ' '\n' | grep -qx dialout; then
        sudo usermod -aG dialout "$ubuntu_user"
    fi

    {
        printf 'Installed at %s\n' "$(date -u +%FT%TZ)"
        printf 'OSS CAD Suite release: %s\nArchitecture: %s\n' "$release" "$architecture"
        printf 'Suite SHA256: %s\n' "$suite_sha256"
        printf 'Tiny Tapeout tools commit: %s\n' "$(git -C "$tt_dir" rev-parse HEAD)"
        git -C "$tt_dir" submodule status --recursive
        python3 --version
        yosys -V
        nextpnr-ice40 --version
        python3 -m pip freeze
    } > "$install_dir/installed-versions.txt"

    printf '\nSetup complete for %s.\n' "$ubuntu_user"
    printf 'Installed tools and revision record: %s\n' "$install_dir"
    printf 'Log out of Ubuntu completely and log in again, or reboot the VM, to activate dialout membership.\n'
    printf 'In a fresh Ubuntu Terminal, run:\n  source %q\n  tt-fpga --help\n' "$install_dir/activate.sh"
    printf '\nOn the host, enable the VM USB controller and attach the MicroPython board using Devices > USB.\n'
    printf 'An optional board-specific USB filter can reconnect it automatically.\n'
    printf 'Then, inside Ubuntu, run: lsusb; python3 -m serial.tools.list_ports -v\n'
}

if [[ ${BASH_SOURCE[0]} == "$0" ]]; then
    main "$@"
fi
