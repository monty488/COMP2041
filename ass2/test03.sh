#!/bin/dash

# This test will check to see if the substitute command
# in speed.pl functions correctly for subset0

# Test if substitute functions
output="1
2
edited
4
5"
output_check=$(seq 1 5 | ./speed.pl 's/3/edited/')
if test ! "$output_check" = "$output"
then
    echo "Test failed"
    exit 1
fi


# Test if substitute removes a line
output="1
2

4
5"
output_check=$(seq 1 5 | ./speed.pl 's/3//')
if test ! "$output_check" = "$output"
then
    echo "Test failed"
    exit 1
fi

# Test if substitute functions
output="1-
11
12
13
14
15
16
17
18
19
2-"
output_check=$(seq 10 20 | ./speed.pl 's/0/-/')
if test ! "$output_check" = "$output"
then
    echo "Test failed"
    exit 1
fi

# Test if substitute functions with the global flag
output="-000
-00-
-002
-003
-004
-005
-006
-007
-008
-009
-0-0"
output_check=$(seq 1000 1010 | ./speed.pl 's/1/-/g')
if test ! "$output_check" = "$output"
then
    echo "Test failed"
    exit 1
fi

# Test if a given line number functions
output="10
11
12
13
--
15
16
17
18
19
20"
output_check=$(seq 10 20 | ./speed.pl '5s/[0-9]/-/g')
if test ! "$output_check" = "$output"
then
    echo "Test failed"
    exit 1
fi

# Test if a given regex functions
output="100
1!0
200
2!0
300
3!0
400
4!0
500
!!0
600
6!0"
output_check=$(seq 100 50 650 | ./speed.pl '/.5./s/5/!/g')
if test ! "$output_check" = "$output"
then
    echo "Test failed"
    exit 1
fi


echo "Test passed"
exit 0