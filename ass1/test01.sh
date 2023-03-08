#!/bin/dash

# This test will check the functionality of girt-log,
# and girt-commit by checking if all the files
# are properly committed.

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

        # Create a file that will be added to the index
        echo "123" > file1
        echo "456" > file2
        echo "789" > file3

        # add the file1 to the index of the repository
        ../girt-add file1

        # commit the file with the message 'commit-0'
        girt_commit_check=$(../girt-commit -m commit-0)
        # check the output that the output of girt-commit is valid
        if test ! "$girt_commit_check" = "Committed as commit 0"
        then
            echo "Test failed"
            exit 1
        fi

        #check that girt-log has the correct information
        girt_log_check=$(../girt-log )
        if test ! "$girt_log_check" = "0 commit-0"
        then
            echo "Test failed"
            exit 1
        fi
        
        # check with girt-show that the file1 appears in the commit folder
        file_check=$(../girt-show 0:file1)
        if test ! "$file_check" = "123"
        then
            echo "Test failed"
            exit 1
        fi

        # add 2 more files into the index for another commit
        ../girt-add file2
        ../girt-add file3
        
        # commit the file with the message 'commit-1'
        girt_commit_check=$(../girt-commit -m commit-1)
        # check the output that the output of girt-commit is valid
        if test ! "$girt_commit_check" = "Committed as commit 1"
        then
            echo "Test failed"
            exit 1
        fi

        #check that girt-log has the correct updated information
        if test ! "$(../girt-log | head -1)" = "1 commit-1"
        then
            echo "Test failed"
            exit 1
        fi
        if test ! "$(../girt-log | tail -1)" = "0 commit-0"
        then
            echo "Test failed"
            exit 1
        fi

        # check with girt-show that the file2 appears in the commit folder
        file_check=$(../girt-show 1:file2)
        if test ! "$file_check" = "456"
        then
            echo "Test failed"
            exit 1
        fi

        # check with girt-show that the file3 appears in the commit folder
        file_check=$(../girt-show 1:file3)
        if test ! "$file_check" = "789"
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