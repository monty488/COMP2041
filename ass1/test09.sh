#!/bin/dash

# This test will test that the functions in subset 1
# and subset 2 produce an error when used before 
# the .girt directory is created

# Create a temporary directory that will be used
# for the test
tmp_dir=$(mktemp -d tmp.XXXXXXXXXX)
trap 'rm -rf ../$tmp_dir; exit' INT TERM EXIT

cd $tmp_dir || exit 1

girt_not_found="error: girt repository directory .girt not found"

check=$(../girt-rm)
if test ! "$check" = "girt-rm: $girt_not_found"
then
    echo "Test failed"
    exit 1
fi

check=$(../girt-status)
if test ! "$check" = "girt-status: $girt_not_found"
then
    echo "Test failed"
    exit 1
fi

check=$(../girt-branch)
if test ! "$check" = "girt-branch: $girt_not_found"
then
    echo "Test failed"
    exit 1
fi

check=$(../girt-checkout)
if test ! "$check" = "girt-checkout: $girt_not_found"
then
    echo "Test failed"
    exit 1
fi

echo "Test passed"