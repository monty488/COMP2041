#!/bin/dash

# Test the functionality of girt-status

# Create a temporary directory that will be used
# for the test
tmp_dir=$(mktemp -d tmp.XXXXXXXXXX)
trap 'rm -rf ../$tmp_dir; exit' INT TERM EXIT

cd $tmp_dir || exit 1

# initialise the girt repository
../girt-init > /dev/null

# Create a file that will be added to the index
echo "123" > file1
echo "456" > file2
echo "789" > file3
output="file1 - untracked
file2 - untracked
file3 - untracked"
status_output=$(../girt-status)
if test ! "$status_output" = "$output"
then
    echo "Test failed"
    exit 1
fi

# add the file to index
../girt-add file1
output="file1 - added to index
file2 - untracked
file3 - untracked" 
status_output=$(../girt-status)
if test ! "$status_output" = "$output"
then
    echo "Test failed"
    exit 1
fi

# commit the file
../girt-commit -m commit-0 > /dev/null
output="file1 - same as repo
file2 - untracked
file3 - untracked" 
status_output=$(../girt-status)
if test ! "$status_output" = "$output"
then
    echo "Test failed"
    exit 1
fi

# change the file
echo "new line" >> file1
output="file1 - file changed, changes not staged for commit
file2 - untracked
file3 - untracked" 
status_output=$(../girt-status)

# stage the change for commit
../girt-add file1
output="file1 - file changed, changes staged for commit
file2 - untracked
file3 - untracked" 
status_output=$(../girt-status)
if test ! "$status_output" = "$output"
then
    echo "Test failed"
    exit 1
fi

# commit the file
../girt-commit -m commit-0 > /dev/null
output="file1 - same as repo
file2 - untracked
file3 - untracked" 
status_output=$(../girt-status)
if test ! "$status_output" = "$output"
then
    echo "Test failed"
    exit 1
fi

# add file2 to index then change it
../girt-add file2
echo "new line" >> file2
output="file1 - same as repo
file2 - added to index, file changed
file3 - untracked" 
status_output=$(../girt-status)
if test ! "$status_output" = "$output"
then
    echo "Test failed"
    exit 1
fi

# add file3 to index then delete it
../girt-add file3
rm file3
output="file1 - same as repo
file2 - added to index, file changed
file3 - added to index, file deleted" 
status_output=$(../girt-status)
if test ! "$status_output" = "$output"
then
    echo "Test failed"
    exit 1
fi


# if all outputs have been correct, then the test has passed
echo "Test passed"
