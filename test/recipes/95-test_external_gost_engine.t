#! /usr/bin/env perl
# Copyright 2024 The OpenSSL Project Authors. All Rights Reserved.
#
# Licensed under the Apache License 2.0 (the "License").  You may not use
# this file except in compliance with the License.  You can obtain a copy
# in the file LICENSE in the source distribution or at
# https://www.openssl.org/source/license.html


use OpenSSL::Test;
use OpenSSL::Test::Utils;
use OpenSSL::Test qw/:DEFAULT data_file srctop_file bldtop_dir/;
use Cwd qw(abs_path);

setup("test_external_gost_engine");

plan skip_all => "No external tests in this configuration"
    if disabled("external-tests");
plan skip_all => "gost-engine not available"
    if ! -f srctop_file("gost-engine", "CMakeLists.txt");

plan tests => 1;

$ENV{OPENSSL_MODULES} = abs_path(bldtop_dir("providers"));
$ENV{OPENSSL_CONF} = abs_path(srctop_file("test", "default-and-legacy.cnf"));

ok(run(cmd([data_file("gost_engine.sh")])), "running gost-engine tests");
