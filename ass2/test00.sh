#!/bin/dash

# This test will check to see if the quit command
# in speed.pl functions correctly for subset0

# Test quit command with a given line num
output="0
1
2
3
4"
output_check=$(seq 0 20 | ./speed.pl '5q')
if test ! "$output_check" = "$output" 
then
    echo "Test failed"
    exit 1
fi

# Test quit with a given regex
output="1
2
3
4
5
6"
output_check=$(seq 1 20 | ./speed.pl '/6/q')
if test ! "$output_check" = "$output" 
then
    echo "Test failed"
    exit 1
fi

# Test quit with a given regex
output="1
2
3
4
5
6
7
8
9
10"
output_check=$(seq 1 20 | ./speed.pl '/1./q')
if test ! "$output_check" = "$output" 
then
    echo "Test failed"
    exit 1
fi

# Test quit with a given regex
output="1
2
3
4
5
6
7
8
9
10
11
12"
output_check=$(seq 1 20 | ./speed.pl '/.2$/q')
if test ! "$output_check" = "$output" 
then
    echo "Test failed"
    exit 1
fi

echo "Test passed"
exit 0

