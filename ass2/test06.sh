#!/bin/dash

# This test will check if different delimiters for 
# substitute command work correctly for subset 1

# Test with a delimiter of Z
output="10
11
12
!!
!!
!!
!!
17
18
19
20"
output_check=$(seq 10 20 | ./speed.pl '4,7sZ[0-9]Z!Zg')
if test ! "$output_check" = "$output"
then
    echo "Test failed"
    exit 1
fi

# Test with a delimiter of _
output="10
11
!!
!!
!!
!!
!!
!!
18
19
20"
output_check=$(seq 10 20 | ./speed.pl '/12/,8s_[0-9]_!_g')
if test ! "$output_check" = "$output"
then
    echo "Test failed"
    exit 1
fi

# Test with a delimiter of ?
output="10
11
12
13
14
!!
!!
!!
!!
!!
20"
output_check=$(seq 10 20 | ./speed.pl '/.5/,/9$/s?[0-9]?!?g')
if test ! "$output_check" = "$output"
then
    echo "Test failed"
    exit 1
fi

# Test with a delimiter of 1
output="10
11
!!
!!
!!
!!
!!
!!
!!
19
20"
output_check=$(seq 10 20 | ./speed.pl '3,/.8/s1[0-9]1!1g')
if test ! "$output_check" = "$output"
then
    echo "Test failed"
    exit 1
fi

echo "Test passed"
exit 0