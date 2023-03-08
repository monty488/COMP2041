#!/bin/dash

# This test will check the errors
# for all the subset 0 functions

# Create a temporary directory that will be used
# for the test
tmp_dir=$(mktemp -d tmp.XXXXXXXXXX)
trap 'rm -rf ../$tmp_dir; exit' INT TERM EXIT

cd $tmp_dir || exit 1
girt_not_found="error: girt repository directory .girt not found"

# Check that the girt functions return an error
# when they are called and the .girt directory does not exist
check=$(../girt-add)
if test ! "$check" = "girt-add: $girt_not_found"
then
    echo "Test failed"
    exit 1
fi

check=$(../girt-commit)
if test ! "$check" = "girt-commit: $girt_not_found"
then
    echo "Test failed"
    exit 1
fi

check=$(../girt-show)
if test ! "$check" = "girt-show: $girt_not_found"
then
    echo "Test failed"
    exit 1
fi

check=$(../girt-log)
if test ! "$check" = "girt-log: $girt_not_found"
then
    echo "Test failed"
    exit 1
fi


# use girt-init to create the .girt folder 
# and check if the folder is created and the exit status is correct
output_check=$(../girt-init)
if test "$output_check" = "Initialized empty girt repository in .girt" && test $? -eq 0
then
    # Test if the .girt directory has been made
    if test -d .girt
    then
        # Check that girt-init produces an error when it is called again
        girt_init_check=$(../girt-init)
        if test ! "$girt_init_check" = "girt-init: error: .girt already exists"
        then
            echo "Test failed"
            exit 1
        fi
        # Use girt-add to add a file that does not exist
        # This is to test if girt-add returns the correct exit status
        girt_add_check=$(../girt-add file1)
        if test ! "$girt_add_check" = "girt-add: error: can not open 'file1'"
        then
            echo "Test failed"
            exit 1
        fi

        # Test that girt-add gives an error for non regular files
        mkdir test_dir
        regular_file_check=$(../girt-add test_dir)
        if test ! "$regular_file_check" = "girt-add: error: 'test_dir' not a regular file"
        then
            echo "Test failed"
            exit 1
        fi

        # Test that girt-commit has nothing to commit initially
        girt_commit_check=$(../girt-commit -m test-commit)
        if test ! "$girt_commit_check" = "nothing to commit"
        then
            echo "Test failed"
            exit 1
        fi

        # Test that girt-show returns the correct error for a file
        # not in the index
        girt_show_check=$(../girt-show :file1)
        if test ! "$girt_show_check" = "girt-show: error: 'file1' not found in index"
        then
            echo "Test failed"
            exit 1
        fi

        # Test that girt-show returns the correct error for a
        # non existent commit
        girt_show_check=$(../girt-show 0:file1)
        if test ! "$girt_show_check" = "girt-show: error: unknown commit '0'"
        then
            echo "Test failed"
            exit 1
        fi

        # create a file, commit it
        echo "123" >> file1
        ../girt-add file1
        ../girt-commit -m commit-0 > /dev/null

        # Test that girt-show retunrs the correct error
        # for a file that does not exist in a commit
        girt_show_check=$(../girt-show 0:file2)
        if test ! "$girt_show_check" = "girt-show: error: 'file2' not found in commit 0"
        then
            echo "Test failed"
            exit 1
        fi

        # if all outputs have been correct, then the test has passed
        echo "Test passed"
    fi
else
    echo "Test failed"
    exit 1
fi