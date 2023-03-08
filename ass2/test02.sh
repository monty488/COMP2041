#!/bin/dash

# This test will check to see if the delete command
# in speed.pl functions correctly for subset0

# Test a normal delete
output_check=$(seq 1 6 | ./speed.pl 'd')
if test ! "$output_check" = ""
then
    echo "Test failed"
    exit 1
fi

# Test a delete with a line num specified
output="1
2
4
5
6"
output_check=$(seq 1 6 | ./speed.pl '3d')
if test ! "$output_check" = "$output"
then
    echo "Test failed"
    exit 1
fi

# Test a delete with a regex
output="0
1
2
4
5
6"
output_check=$(seq 0 6 | ./speed.pl '/3/d')
if test ! "$output_check" = "$output"
then
    echo "Test failed"
    exit 1
fi

# Test a delete with a regex
output="0
1
2
3
4
5
6
7
8
9
10"
output_check=$(seq 0 11 | ./speed.pl '/.1/d')
if test ! "$output_check" = "$output"
then
    echo "Test failed"
    exit 1
fi

echo "Test passed"
exit 0