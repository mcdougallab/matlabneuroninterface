#!/usr/bin/env bash
# Installer for NEURON Toolbox for MATLAB
# Automates the first-time setup described in README.md

set -uo pipefail

TOOLBOX_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OS="$(uname -s)"   # Darwin or Linux

# ── Helpers ───────────────────────────────────────────────────────────────────

die()  { echo ""; echo "ERROR: $*" >&2; exit 1; }
info() { echo "  $*"; }

ask() {
    printf "\n  %s\n  > " "$*"
    read -r REPLY
    echo "$REPLY"
}

# Append a line to a file only if it is not already present
append_if_absent() {
    local file="$1" line="$2"
    if grep -qF "$line" "$file" 2>/dev/null; then
        info "Already present in $(basename "$file"), skipping"
    else
        printf '\n%s\n' "$line" >> "$file"
        info "Added to $file"
    fi
}

# ── Step 1: Find NEURON ───────────────────────────────────────────────────────

echo ""
echo "=== Step 1: Locating NEURON installation ==="

NRN_DATA_DIR=""

try_nrn_dir() {
    # Accepts a candidate "data root" and sets NRN_DATA_DIR if libnrniv is present
    local dir="$1"
    if [[ -f "$dir/lib/libnrniv.dylib" || -f "$dir/lib/libnrniv.so" ]]; then
        NRN_DATA_DIR="$dir"
        return 0
    fi
    return 1
}

# Preferred: pip-installed NEURON — gives us the exact .data directory
# Prefer `python` (picks up the active conda env) over the system `python3`
_PYTHON="$(command -v python 2>/dev/null || command -v python3 2>/dev/null)"
if [[ -n "$_PYTHON" ]]; then
    _nrn_init="$("$_PYTHON" -c "import neuron; print(neuron.__file__)" 2>/dev/null)" || true
    if [[ -n "$_nrn_init" ]]; then
        try_nrn_dir "$(dirname "$_nrn_init")/.data" \
            && info "Found NEURON (pip) at: $NRN_DATA_DIR"
    fi
fi

# Fallback: common system-wide install locations
if [[ -z "$NRN_DATA_DIR" ]]; then
    for _candidate in /Applications/nrn /usr/local/nrn /opt/nrn /usr/local; do
        try_nrn_dir "$_candidate" && { info "Found NEURON at: $NRN_DATA_DIR"; break; }
    done
fi

# Ask the user
if [[ -z "$NRN_DATA_DIR" ]]; then
    echo ""
    echo "  NEURON was not found automatically."
    echo "  Install NEURON 9+ from https://www.neuronsimulator.org, or run:"
    echo "    pip install neuron"
    echo ""
    echo "  If NEURON is already installed, provide the path to its data root —"
    echo "  the directory that contains lib/libnrniv and include/neuronapi.h."
    echo "  (For a pip install this is the .data/ directory inside the Python package.)"
    NRN_DATA_DIR="$(ask "NEURON data directory:")"
    [[ -d "$NRN_DATA_DIR" ]] || die "Directory not found: $NRN_DATA_DIR"
fi

if [[ "$OS" == "Darwin" ]]; then
    LIBNRNIV="$NRN_DATA_DIR/lib/libnrniv.dylib"
    LIBMODLREG="$TOOLBOX_DIR/libmodlreg.dylib"
else
    LIBNRNIV="$NRN_DATA_DIR/lib/libnrniv.so"
    LIBMODLREG="$TOOLBOX_DIR/libmodlreg.so"
fi
NEURONAPI_H="$NRN_DATA_DIR/include/neuronapi.h"
HOC_DIR="$NRN_DATA_DIR/share/nrn/lib/hoc"

[[ -f "$LIBNRNIV" ]]    || die "libnrniv not found at: $LIBNRNIV"
[[ -f "$NEURONAPI_H" ]] || die "neuronapi.h not found at: $NEURONAPI_H"
[[ -d "$HOC_DIR" ]]     || die "HOC directory not found at: $HOC_DIR"

info "libnrniv:    $LIBNRNIV"
info "neuronapi.h: $NEURONAPI_H"
info "HOC dir:     $HOC_DIR"

# ── Step 2: Find MATLAB ───────────────────────────────────────────────────────

echo ""
echo "=== Step 2: Locating MATLAB ==="

MATLAB_BIN=""

# Check PATH first
command -v matlab &>/dev/null && MATLAB_BIN="$(command -v matlab)"

# macOS: scan /Applications for newest MATLAB app bundle
if [[ -z "$MATLAB_BIN" && "$OS" == "Darwin" ]]; then
    MATLAB_BIN="$(ls -d /Applications/MATLAB_R*.app/bin/matlab 2>/dev/null \
                  | sort -V | tail -1)" || true
fi

# Linux: scan /usr/local/MATLAB
if [[ -z "$MATLAB_BIN" && "$OS" == "Linux" ]]; then
    MATLAB_BIN="$(ls /usr/local/MATLAB/*/bin/matlab 2>/dev/null \
                  | sort -V | tail -1)" || true
fi

if [[ -z "$MATLAB_BIN" ]]; then
    MATLAB_BIN="$(ask "MATLAB executable not found. Enter its full path:")"
    [[ -x "$MATLAB_BIN" ]] || die "Not executable: $MATLAB_BIN"
fi

info "MATLAB binary: $MATLAB_BIN"

# Derive matlabroot — prefer asking MATLAB itself, fall back to path inference
echo "  Querying MATLAB for matlabroot (this may take a moment) ..."
MATLAB_ROOT="$("$MATLAB_BIN" -batch "fprintf('%s\n', matlabroot)" 2>/dev/null \
               | grep -E '^/' | head -1 | tr -d '[:space:]')" || true

if [[ -z "$MATLAB_ROOT" ]]; then
    # Fallback: resolve symlink, then go up two directories from .../bin/matlab
    _real="$(readlink -f "$MATLAB_BIN" 2>/dev/null \
             || "${_PYTHON:-python3}" -c "import os,sys; print(os.path.realpath(sys.argv[1]))" "$MATLAB_BIN" \
             || echo "$MATLAB_BIN")"
    MATLAB_ROOT="$(dirname "$(dirname "$_real")")"
fi

[[ -d "$MATLAB_ROOT" ]] || die "Could not determine matlabroot; got: $MATLAB_ROOT"
info "matlabroot: $MATLAB_ROOT"

# Detect MATLAB architecture (reflects what MATLAB was compiled as, not the Mac's CPU)
if [[ "$OS" == "Darwin" ]]; then
    if [[ -d "$MATLAB_ROOT/bin/maca64" ]]; then
        MATLAB_ARCH="maca64"
    else
        MATLAB_ARCH="maci64"
    fi
else
    MATLAB_ARCH="glnxa64"
fi
MATLAB_LIB_DIR="$MATLAB_ROOT/bin/$MATLAB_ARCH"
info "MATLAB arch dir: $MATLAB_LIB_DIR"

# Detect the macOS deployment target MATLAB was built for by reading libmex.dylib.
# This must match what the linker uses, otherwise MEX symbols are left undefined.
if [[ "$OS" == "Darwin" ]]; then
    _libmex="$MATLAB_LIB_DIR/libmex.dylib"
    MACOS_DEPLOY_TARGET=""
    if [[ -f "$_libmex" ]]; then
        # vtool is more reliable on macOS 12+; fall back to otool for older hosts
        MACOS_DEPLOY_TARGET="$(vtool -show-build "$_libmex" 2>/dev/null \
            | awk '/minos/{print $2; exit}')" || true
        if [[ -z "$MACOS_DEPLOY_TARGET" ]]; then
            MACOS_DEPLOY_TARGET="$(otool -l "$_libmex" 2>/dev/null \
                | awk '/LC_VERSION_MIN_MACOSX/{f=1} f && /[[:space:]]version /{print $2; exit}')" || true
        fi
    fi
    MACOS_DEPLOY_TARGET="${MACOS_DEPLOY_TARGET:-11.0}"
    info "MATLAB macOS deployment target: $MACOS_DEPLOY_TARGET"
fi

# ── Step 3: Patch source/neuron_api.cpp ──────────────────────────────────────

echo ""
echo "=== Step 3: Patching source/neuron_api.cpp ==="

CPP_FILE="$TOOLBOX_DIR/source/neuron_api.cpp"
[[ -f "$CPP_FILE" ]] || die "Not found: $CPP_FILE"

# Patch to a temp file — the original source is never modified
_PATCHED_CPP="$(mktemp /tmp/neuron_api_XXXXXX.cpp)"
export CPP_FILE NEURONAPI_H LIBNRNIV LIBMODLREG PATCHED_CPP="$_PATCHED_CPP"

"${_PYTHON:-python3}" - <<PYEOF || { rm -f "$_PATCHED_CPP"; die "Failed to patch neuron_api.cpp"; }
import os

src         = os.environ['CPP_FILE']    # original, never written
dst         = os.environ['PATCHED_CPP'] # temp file
neuronapi_h = os.environ['NEURONAPI_H']
libnrniv    = os.environ['LIBNRNIV']
libmodlreg  = os.environ['LIBMODLREG']

with open(src, 'r') as f:
    content = f.read()

def require_replace(text, old, new, label):
    if old not in text:
        print(f'  WARNING: expected pattern not found for {label}: {old!r}', flush=True)
        return text
    return text.replace(old, new)

content = require_replace(content,
    '#include "/usr/local/include/neuronapi.h"',
    f'#include "{neuronapi_h}"',
    'neuronapi.h include')

content = require_replace(content,
    'DLL_LOAD("/usr/local/lib/libnrniv.dylib")',
    f'DLL_LOAD("{libnrniv}")',
    'libnrniv path')

content = require_replace(content,
    'DLL_LOAD_GLOBAL("libmodlreg.dylib")',
    f'DLL_LOAD_GLOBAL("{libmodlreg}")',
    'libmodlreg path')

with open(dst, 'w') as f:
    f.write(content)

print(f'  Patched (temp): {dst}', flush=True)
PYEOF

info "neuronapi.h  → $NEURONAPI_H"
info "libnrniv     → $LIBNRNIV"
info "libmodlreg   → $LIBMODLREG"

# ── Step 4: Compile libmodlreg ────────────────────────────────────────────────

echo ""
echo "=== Step 4: Compiling libmodlreg ==="

if [[ "$OS" == "Darwin" ]]; then
    cc -dynamiclib -undefined dynamic_lookup -o "$LIBMODLREG" "$TOOLBOX_DIR/source/modl_reg.c" \
        || die "Failed to compile libmodlreg"
else
    cc -shared -fPIC -o "$LIBMODLREG" "$TOOLBOX_DIR/source/modl_reg.c" \
        || die "Failed to compile libmodlreg"
fi

info "Compiled: $LIBMODLREG"

# ── Step 5: Compile neuron_api MEX ───────────────────────────────────────────

echo ""
echo "=== Step 5: Compiling neuron_api MEX ==="

_mex_ok=0

# First attempt: use MATLAB's mex command (macOS only).
# On Linux, MATLAB's mex does not reliably pass -static-libstdc++ through the
# compiler driver, so the resulting MEX ends up with a dynamic libstdc++
# dependency that conflicts with MATLAB's own older bundled libstdc++.
# We skip directly to the direct-compiler fallback on Linux.
if [[ "$OS" == "Darwin" ]]; then
    MEX_CMDS="cd('$TOOLBOX_DIR')"
    MEX_CMDS+="; setenv('MACOSX_DEPLOYMENT_TARGET','$MACOS_DEPLOY_TARGET')"
    MEX_CMDS+="; mex('CXXFLAGS=-std=c++17', '-output', fullfile('$TOOLBOX_DIR','neuron_api'), '$_PATCHED_CPP')"

    echo "  Trying mex ..."
    if "$MATLAB_BIN" -batch "$MEX_CMDS" >/dev/null 2>&1; then
        info "MEX compilation succeeded (via mex)"
        _mex_ok=1
    fi
else
    echo "  Skipping mex on Linux (using direct compiler to ensure -static-libstdc++) ..."
fi

if [[ "$_mex_ok" -eq 0 ]]; then
    # Direct-compiler path: bypasses mex's linker flags, giving full control.
    # On Linux this is always taken (see above). On macOS it is a fallback when
    # mex fails (e.g. linker incompatibility). Without cpp_mexapi_version.o,
    # MATLAB falls back to the C API and calls mexFunction directly — which is
    # what neuron_api.cpp provides.
    [[ "$OS" == "Linux" ]] || echo "  mex compilation failed; using direct compiler fallback ..."

    case "$MATLAB_ARCH" in
        maca64)  _arch="-arch arm64";   _mex_ext="mexmaca64" ;;
        maci64)  _arch="-arch x86_64";  _mex_ext="mexmaci64" ;;
        glnxa64) _arch="";              _mex_ext="mexa64" ;;
        *)       _arch="";              _mex_ext="mex" ;;
    esac

    # Use clang++ on macOS; prefer g++ on Linux where clang++ may not be installed
    if [[ "$OS" == "Darwin" ]]; then
        _CXX=clang++
    else
        _CXX="$(command -v g++ 2>/dev/null || command -v clang++ 2>/dev/null || command -v c++ 2>/dev/null)" \
            || die "No C++ compiler found; install g++ and retry"
    fi

    _mex_out="$TOOLBOX_DIR/neuron_api.$_mex_ext"
    MATLAB_INCLUDE="$MATLAB_ROOT/extern/include"

    if [[ "$OS" == "Darwin" ]]; then
        _deploy="-mmacosx-version-min=$MACOS_DEPLOY_TARGET"
        _link="-bundle -L$MATLAB_LIB_DIR -lmex -lmx -Wl,-rpath,$MATLAB_LIB_DIR"
    else
        _deploy=""
        # -static-libstdc++ embeds libstdc++ into the MEX so it is insulated from
        # whichever libstdc++ MATLAB loads at runtime (MATLAB ships an older copy).
        _link="-shared -static-libstdc++ -L$MATLAB_LIB_DIR -lmex -lmx -Wl,-rpath,$MATLAB_LIB_DIR"
    fi

    _tmpobj="$(mktemp /tmp/neuron_api_XXXXXX.o)"
    "$_CXX" -std=c++17 $_arch $_deploy \
        -fPIC -DMATLAB_MEX_FILE \
        -I"$MATLAB_INCLUDE" \
        -I"$NRN_DATA_DIR/include" \
        -c "$_PATCHED_CPP" \
        -o "$_tmpobj" \
        || { rm -f "$_tmpobj" "$_PATCHED_CPP"; die "Compilation of neuron_api.cpp failed"; }

    "$_CXX" $_arch $_deploy $_link \
        "$_tmpobj" \
        -o "$_mex_out" \
        || { rm -f "$_tmpobj" "$_PATCHED_CPP"; die "Linking neuron_api MEX failed"; }

    rm -f "$_tmpobj"
    info "Built: $_mex_out"
fi

rm -f "$_PATCHED_CPP"

# ── Step 6: Configure shell environment and MATLAB startup.m ─────────────────

echo ""
echo "=== Step 6: Configuring shell environment ==="

# MATLABPATH: lets MATLAB find the toolbox when launched from a terminal
MATLABPATH_LINE="export MATLABPATH=\"\${MATLABPATH:+\${MATLABPATH}:}$TOOLBOX_DIR\""

# HOC_LIBRARY_PATH: required for NEURON to find its .hoc standard library files
HOC_LINE="export HOC_LIBRARY_PATH=\"\${HOC_LIBRARY_PATH:+\${HOC_LIBRARY_PATH}:}$HOC_DIR\""

# Library search path: MATLAB arch dir, NEURON libs, and toolbox root (for libmodlreg)
if [[ "$OS" == "Darwin" ]]; then
    # Note: SIP strips DYLD_LIBRARY_PATH when launching protected executables.
    # Set it here for shells that launch MATLAB via this environment; if MATLAB
    # strips it, see doc/example_startup_scripts/mac_matlab.sh for the workaround.
    MATLAB_SYS_LIB_DIR="$MATLAB_ROOT/sys/os/$MATLAB_ARCH"
    LIBPATH_LINE="export DYLD_LIBRARY_PATH=\"\${DYLD_LIBRARY_PATH:+\${DYLD_LIBRARY_PATH}:}$MATLAB_LIB_DIR:$MATLAB_SYS_LIB_DIR:$NRN_DATA_DIR/lib:$TOOLBOX_DIR\""
else
    LIBPATH_LINE="export LD_LIBRARY_PATH=\"\${LD_LIBRARY_PATH:+\${LD_LIBRARY_PATH}:}$MATLAB_LIB_DIR:$NRN_DATA_DIR/lib:$TOOLBOX_DIR\""
fi

_updated_any=0
for rc in "$HOME/.bashrc" "$HOME/.zshrc"; do
    [[ -f "$rc" ]] || continue
    echo "  Updating $rc ..."
    append_if_absent "$rc" "$MATLABPATH_LINE"
    append_if_absent "$rc" "$HOC_LINE"
    append_if_absent "$rc" "$LIBPATH_LINE"
    _updated_any=1
done

if [[ "$_updated_any" -eq 0 ]]; then
    echo "  Neither ~/.bashrc nor ~/.zshrc found; add these lines manually:"
    echo "    $MATLABPATH_LINE"
    echo "    $HOC_LINE"
    echo "    $LIBPATH_LINE"
fi

# startup.m runs on every MATLAB launch regardless of how MATLAB was started,
# making this more reliable than MATLABPATH in shell rc files alone.
echo "  Updating MATLAB startup.m ..."
MATLAB_USERPATH="$("$MATLAB_BIN" -batch "fprintf('%s\\n', userpath)" 2>/dev/null \
    | tr -d '[:space:]')" || true
[[ -z "$MATLAB_USERPATH" ]] && MATLAB_USERPATH="$HOME/Documents/MATLAB"
mkdir -p "$MATLAB_USERPATH"
STARTUP_M="$MATLAB_USERPATH/startup.m"
append_if_absent "$STARTUP_M" "addpath('$TOOLBOX_DIR');"
append_if_absent "$STARTUP_M" "setenv('HOC_LIBRARY_PATH', '$HOC_DIR');"
info "startup.m: $STARTUP_M"

# ── Done ──────────────────────────────────────────────────────────────────────

echo ""
echo "=== Installation complete ==="
echo ""
echo "Reload your shell environment, then verify the install inside MATLAB with:"
echo "  run('$TOOLBOX_DIR/examples/basic_functionality/example_run.m')"
echo "  run('$TOOLBOX_DIR/examples/simulation/example_acpot.m')"
echo ""
if [[ "$OS" == "Darwin" ]]; then
    echo "NOTE (macOS): if MATLAB cannot find libmodlreg or libnrniv at runtime, see:"
    echo "  $TOOLBOX_DIR/doc/example_startup_scripts/mac_matlab.sh"
    echo "  Launch MATLAB from that script to work around SIP stripping DYLD_LIBRARY_PATH."
    echo ""
fi
