#!/bin/dash

# This test will check the functionality of girt-rm

# Create a temporary directory that will be used
# for the test
tmp_dir=$(mktemp -d tmp.XXXXXXXXXX)
trap 'rm -rf ../$tmp_dir; exit' INT TERM EXIT

cd $tmp_dir || exit 1

# use girt-init to create the .girt folder 
# and check if the folder is created and the exit status is correct
output_check=$(../girt-init)
if test "$output_check" = "Initialized empty girt repository in .girt" && test $? -eq 0
then

    # Create a file that will be added to the index
    echo "123" > file1
    echo "456" > file2
    echo "789" > file3

    # add the file to the index of the repository
    ../girt-add file1 file2 file3

    # commit the files with the message 'commit-0'
    girt_commit_check=$(../girt-commit -m commit-0)

    # remove the file from index and current directory
    ../girt-rm file1
    
    # check that the file was removed from the current directory
    if test -f file1 
    then
        echo "Test failsed"
        exit 1
    fi

    # commit the change
    girt_commit_check=$(../girt-commit -m commit-1)

    # check that the file was removed from the latest commit
    file1_check=$(../girt-show 1:file1)
    # If girt-show has the incorrect output for the file, test has failed
    if test ! "$file1_check" = "girt-show: error: 'file1' not found in commit 1"
    then
        echo "Test failed"
        exit 1
    fi

    # Test that girt-rm --cached functions
    ../girt-rm --cached file2

    # Check the file was removed from the index
    file2_check=$(../girt-show :file2)
    if test ! "$file2_check" = "girt-show: error: 'file2' not found in index"
    then
        echo "Test failed"
        exit 1
    fi

    # Test that girt-rm will give an error when the file is changed in
    # the current directory
    echo "changed line" > file3
    rm_check=$(../girt-rm file3)
    output="girt-rm: error: 'file3' in the repository is different to the working file"
    if test ! "$rm_check" = "$output"
    then
        echo "Test failed"
        exit 1
    fi

    # Test that girt-rm will give an error when the file is different
    # in both the commit, index and current directory
    ../girt-add file3
    echo "changed line gain" > file3
    rm_check=$(../girt-rm file3)
    output="girt-rm: error: 'file3' in index is different to both to the working file and the repository"
    if test ! "$rm_check" = "$output"
    then
        echo "Test failed"
        exit 1
    fi    

    # Test that girt-rm will give an error when the file does not exit
    rm_check=$(../girt-rm file4)
    output="girt-rm: error: 'file4' is not in the girt repository"
    if test ! "$rm_check" = "$output"
    then
        echo "Test failed"
        exit 1
    fi   
    # if all outputs have been correct, then the test has passed
    echo "Test passed"

else
    echo "Test failed"
    exit 1
fi