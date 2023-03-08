#!/bin/dash

# This test will check to see if the print command
# in speed.pl functions correctly for subset0

# Test if print command functions
output="1
1
2
2
3
3
4
4
5
5
6
6"
output_check=$(seq 1 6 | ./speed.pl 'p')
if test ! "$output_check" = "$output"
then
    echo "Test failed"
    exit 1
fi

# Test if print functions with -n flag
output="1
2
3
4
5
6"
output_check=$(seq 1 6 | ./speed.pl -n 'p')
if test ! "$output_check" = "$output"
then
    echo "Test failed"
    exit 1
fi

# Test print command with a given regex
output="1
10
11
12
13
14
15
16
17
18
19
21
31
41
51
61
71
81
91
100"
output_check=$(seq 1 100 | ./speed.pl -n '/1/p')
if test ! "$output_check" = "$output"
then
    echo "Test failed"
    exit 1
fi

echo "Test passed"
exit 0