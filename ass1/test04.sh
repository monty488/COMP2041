#!/bin/dash

# This test will check the functionality
# of girt-commit -a, as well as check if 
# it functions properly when files are removed
# from the current directory

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

    # commit the files with the message 'commit-0'
    girt_commit_check=$(../girt-commit -m commit-0)

    # Check the file exists in the commit by using girt-show
    file1_check=$(../girt-show 0:file1)
    # If girt-show has the incorrect output for the file, test has failed
    if test ! "$file1_check" = "123"
    then
        echo "Test failed"
        exit 1
    fi

    # change the line in file1, commit it using commit -a
    echo "changed line" > file1
    ../girt-commit -a -m commit-1 > /dev/null

    # check that the file has successfully been committed
    file1_check=$(../girt-show 1:file1)
    # If girt-show has the incorrect output for the file, test has failed
    if test ! "$file1_check" = "changed line"
    then
        echo "Test failed"
        exit 1
    fi

    # remove the file, use commit -a to commit the changes
    rm file1
    ../girt-commit -a -m commit-2 > /dev/null


    # check that the changes has successfully been committed
    file1_check=$(../girt-show 2:file1)
    # If girt-show has the incorrect output for the file, test has failed
    if test ! "$file1_check" = "girt-show: error: 'file1' not found in commit 2"
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