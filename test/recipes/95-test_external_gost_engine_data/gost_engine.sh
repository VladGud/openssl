#!/usr/bin/env bash
# --------------------------------------------------------------
# Wrapper for the gost-engine external test suite.
# --------------------------------------------------------------
# This script is invoked from the test harness.
# It:
#   1. Ensures the gost-engine submodule is initialized and updated
#      to the latest upstream version (with OpenSSL 4.x support).
#   2. Configures and builds the GOST provider (not engine, since
#      this OpenSSL is built with no-engine).
#   3. Runs the gost-engine provider test suite (including TLS 1.2/1.3 tests).
#   4. Returns the test exit status.
# --------------------------------------------------------------

set -euo pipefail

# Find the repository root (go up 3 levels from test/recipes/95-test_external_gost_engine_data/)
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../../.." && pwd)"
GOST_DIR="$ROOT_DIR/gost-engine"

echo "==> Checking gost-engine submodule at: $GOST_DIR"

# Initialize submodule if not already done
if [ ! -f "$GOST_DIR/CMakeLists.txt" ]; then
    echo "==> Initializing gost-engine submodule..."
    cd "$ROOT_DIR"
    git submodule update --init
fi

# Update to latest upstream (with OpenSSL 4.x support)
echo "==> Updating gost-engine to latest upstream version..."
cd "$GOST_DIR"
git fetch origin
git checkout origin/master

# Initialize nested submodules (e.g., libprov)
echo "==> Initializing gost-engine nested submodules..."
git submodule update --init --recursive

echo "==> Configuring and building gost-engine provider (engine build disabled)..."
cd "$GOST_DIR"

# Clean build directory
rm -rf build
mkdir -p build
cd build

# Configure with OpenSSL root pointing to our build
cmake .. \
    -DOPENSSL_ROOT_DIR="$ROOT_DIR" \
    -DOPENSSL_ENGINES_DIR="$ROOT_DIR/engines" \
    -DOPENSSL_MODULES_DIR="$ROOT_DIR/providers"

# Build the provider and all test binaries
echo "==> Building gost provider and test suite..."
make gost_prov test_digest test_ciphers test_context test_tls12additional

echo "==> Running gost-engine PROVIDER test suite..."
echo "    (Engine tests are skipped since OpenSSL is built with no-engine)"
echo "    Tests include: digest, ciphers, context, TLS 1.2/1.3 additional"

# Run only provider-specific tests
# These tests use OPENSSL_MODULES and provider.cnf instead of engine.cnf
ctest -R "with-provider" --output-on-failure

echo ""
echo "==> gost-engine provider tests completed successfully!"
echo "    All provider tests passed (including TLS 1.2/1.3 support)"
