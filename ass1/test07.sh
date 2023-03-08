#!/bin/dash

# This test will check the functionality of girt-branch

# Create a temporary directory that will be used
# for the test
tmp_dir=$(mktemp -d tmp.XXXXXXXXXX)
trap 'rm -rf ../$tmp_dir; exit' INT TERM EXIT

cd $tmp_dir || exit 1

# initialise the girt repository
../girt-init > /dev/null

# check that girt-branch produces an error
# when there is no commit
output_check=$(../girt-branch b1)
output="girt-branch: error: this command can not be run until after the first commit"
if test ! "$output_check" = "$output"
then
    echo "Test failed"
    exit 1
fi

# create the first commit
echo "123" > file1
../girt-add file1
../girt-commit -m commit-0 file1 > /dev/null
output_check=$(../girt-branch b1)
if test ! "$output_check" = ""
then
    echo "Test failed"
    exit 1
fi

# check that girt-branch can delete a branch
output_check=$(../girt-branch -d b1)
if test ! "$output_check" = "Deleted branch 'b1'"
then
    echo "Test failed"
    exit 1
fi

# Check that girt-branch has an error when 
# attempting to delete the master branch
output_check=$(../girt-branch -d master)
if test ! "$output_check" = "girt-branch: error: can not delete branch 'master'"
then
    echo "Test failed"
    exit 1
fi

# check that girt-branch has an error
# when attempting to delete a branch that doesnt exist
output_check=$(../girt-branch -d b2)
if test ! "$output_check" = "girt-branch: error: branch 'b2' doesn't exist"
then
    echo "Test failed"
    exit 1
fi




echo "Test passed"
