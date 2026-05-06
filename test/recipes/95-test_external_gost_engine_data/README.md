# GOST Engine External Tests

This directory contains integration tests for the GOST cryptographic engine provider.

## Overview

The `gost_engine.sh` script runs the upstream test suite from the [gost-engine](https://github.com/gost-engine/engine) project.

Since this OpenSSL build is configured with `no-engine`, only **provider tests** are executed (ENGINE-based tests are skipped).

## Running Tests

### Via OpenSSL Test Harness

```bash
# Run through the test recipes system (if external-tests enabled):
make test TESTS="95-test_external_gost_engine"
```

### Direct Execution

```bash
# Run the wrapper script directly:
./test/recipes/95-test_external_gost_engine_data/gost_engine.sh
```

## What Gets Tested

The test suite includes:

* **Digest algorithms** - GOST R 34.11-94, GOST R 34.11-2012 (256/512 bit)
* **Cipher algorithms** - GOST 28147-89, Kuznyechik, Magma
* **Context handling** - Provider initialization and cleanup
* **TLS 1.2/1.3 support** - Additional TLS tests for GOST ciphersuites

## Submodule Management

The script automatically:

1. Initializes the `gost-engine` submodule (if needed)
2. Updates to the latest upstream `master` branch (with OpenSSL 4.x support)
3. Initializes nested submodules (e.g., `libprov`)
4. Builds the GOST provider module
5. Runs the provider test suite via `ctest`

## Requirements

* OpenSSL 3.4+ (built from this repository)
* CMake 3.18+
* Git (for submodule management)

## Notes

* The upstream gost-engine warns about missing `EVP_CTRL_SET_TLSTREE_PARAMS` - this is expected and does not affect test results.
* Engine-based tests are skipped because this OpenSSL is built with `no-engine` and `no-dynamic-engine` options.
* The provider is built as a shared module (`gostprov.dylib`/`gostprov.so`) and loaded via the OpenSSL provider interface.
