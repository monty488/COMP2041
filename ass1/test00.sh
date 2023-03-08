#!/bin/dash

# This test will initialise the .girt repository,
# and check if girt-add and girt-show function properly
# by adding files to the index and making sure the files
# in the index are correct.
# This test will also test if girt-add gives the proper exception
# for when it is given a file that does not exist

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
    # Test if the .girt directory has been made
    if test -d .girt
    then
        # Check that girt-init returns an error that .girt already exists
        girt_check=$(../girt-init)
        if test ! "$girt_check" = "girt-init: error: .girt already exists"
        then
            echo "Test failed"
            exit 1
        fi

        # Use .girt-add to add a file that does not exist
        # This is to test if girt-add returns the correct exit status
        girt_add_check=$(../girt-add file1)
        if test ! "$girt_add_check" = "girt-add: error: can not open 'file1'" && test $? -ne 1
        then
            echo "Test failed"
            exit 1
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

        # if all outputs have been correct, then the test has passed
        echo "Test passed"

    fi
else
    echo "Test failed"
    exit 1
fi
