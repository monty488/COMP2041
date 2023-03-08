#!/bin/dash

# This test will test the cases where
# a file is removed from the current directory
# but still exists in the index

tmp_dir=$(mktemp -d tmp.XXXXXXXXXX)
trap 'rm -rf ../$tmp_dir; exit' INT TERM EXIT

cd $tmp_dir || exit 1

# use girt-init to create the .girt folder 
# and check if the folder is created and the exit status is correct
output_check=$(../girt-init)
if test "$output_check" = "Initialized empty girt repository in .girt" && test $? -eq 0
then
    # Test if the .girt directory has been made
    if test -d .girt
    then
        # Use .girt-add to add a file that does not exist
        # This is to test if girt-add returns the correct exit status
        girt_add_check=$(../girt-add file1)
        if test ! "$girt_add_check" = "girt-add: error: can not open 'file1'" && test $? -ne 1
        then
            echo "Test failed"
        fi

        # Create a file that will be added to the index
        echo "123" > file1

        # add the file to the index of the repository
        ../girt-add file1
        # Check the file exists in the index by using girt-show
        file1_check=$(../girt-show :file1)
        # If girt-show has the incorrect output for the file, test has failed
        if test ! "$file1_check" = "123"
        then
            echo "Test failed"
            exit 1
        fi

        # Create two new files, and add them to the index with girt-show
        echo "456" > file2
        echo "789" > file3
        ../girt-add file2 file3

        file2_check=$(../girt-show :file2)
        # If girt-show has the incorrect output for the file, test has failed
        if test ! "$file2_check" = "456"
        then
            echo "Test failed"
            exit 1
        fi

        file3_check=$(../girt-show :file3)
        if test ! "$file3_check" = "789"
        then
            echo "Test failed"
            exit 1
        fi

        # commit the files with the message 'commit-0'
        girt_commit_check=$(../girt-commit -m commit-0)

        # remove file1 and add the change to the index
        rm file1
        ../girt-add file1

        # check with girt-show that the files appears in the commit folder
        file_check=$(../girt-show 0:file1)
        if test ! "$file_check" = "123"
        then
            echo "Test failed"
            exit 1
        fi
        file_check=$(../girt-show 0:file2)
        if test ! "$file_check" = "456"
        then
            echo "Test failed"
            exit 1
        fi
        file_check=$(../girt-show 0:file3)
        if test ! "$file_check" = "789"
        then
            echo "Test failed"
            exit 1
        fi
        # commit the change with the message 'commit-1'
        girt_commit_check=$(../girt-commit -m commit-1)

        # check that file1 does not appear in the latest commit
        file_check=$(../girt-show 1:file1)
        if test ! "$file_check" = "girt-show: error: 'file1' not found in commit 1"
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
