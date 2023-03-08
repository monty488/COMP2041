#!/bin/dash

# This test will test the functionality of girt-checkout

# Create a temporary directory that will be used
# for the test
tmp_dir=$(mktemp -d tmp.XXXXXXXXXX)
trap 'rm -rf ../$tmp_dir; exit' INT TERM EXIT

cd $tmp_dir || exit 1


# initialise the girt repository
../girt-init > /dev/null

# create a branch b1
echo "123" > file1
../girt-add file1
../girt-commit -m commit-0 file1 > /dev/null
../girt-branch b1

# check that girt-checkout can switch to a branch
output=$(../girt-checkout b1)
if test ! "$output" = "Switched to branch 'b1'"
then
    echo "Test failed"
    exit 1
fi

# check that girt-checkout gives an error
# when already on the branch to switch to
output=$(../girt-checkout b1)
if test ! "$output" = "Already on 'b1'"
then
    echo "Test failed"
    exit 1
fi


# check that girt-checkout gives an error
# when attempting to checkout to a branch that does not exist
output=$(../girt-checkout b2)
if test ! "$output" = "girt-checkout: error: unknown branch 'b2'"
then
    echo "Test failed"
    exit 1
fi

echo "Test passed"