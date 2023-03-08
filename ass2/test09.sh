#!/bin/dash

# This test will check to see if speed.pl gives
# the correct usage messages
output="usage: ./speed.pl [-i] [-n] [-f <script-file> | <sed-command>] [<files>...]"

# check if output is correct with no arguments given
output_check="$(./speed.pl)"
if test ! "$output_check" = "$output"
then
    echo "Test failed"
    exit 1
fi

# check if output is correct with --help flag
output_check="$(./speed.pl --help)"
if test ! "$output_check" = "$output"
then
    echo "Test failed"
    exit 1
fi

echo "Test passed"
exit 0
