#!/bin/dash

# This test will check that the ranges work correctly
# for subset 1

# Test line num and line num as range
output="10
10
11
11
12
12
13
13
14
15
16
17
18
19
20"
output_check=$(seq 10 20 | ./speed.pl '1,4p')
if test ! "$output_check" = "$output"
then
    echo "Test failed"
    exit 1
fi

# Test regex and line num as range
output="10
11
11
12
12
13
13
14
15
16
17
18
19
20"
output_check=$(seq 10 20 | ./speed.pl '/11/,4p')
if test ! "$output_check" = "$output"
then
    echo "Test failed"
    exit 1
fi

# Test with line num and regex as range
output="10
10
11
11
12
12
13
13
14
14
15
15
16
17
18
19
20"
output_check=$(seq 10 20 | ./speed.pl '1,/15/p')
if test ! "$output_check" = "$output"
then
    echo "Test failed"
    exit 1
fi

# Test with line num and line num as range
output="14
15
16
17
18
19
20"
output_check=$(seq 10 20 | ./speed.pl '1,4d')
if test ! "$output_check" = "$output"
then
    echo "Test failed"
    exit 1
fi

# Test with regex and line num as range
output="10
11
12
13
14
15
20"
output_check=$(seq 10 20 | ./speed.pl '/16/,10d')
if test ! "$output_check" = "$output"
then
    echo "Test failed"
    exit 1
fi

# Test with regex and regex as a range
output="10
11
12
13
14
20"
output_check=$(seq 10 20 | ./speed.pl '/15/,/19/d')
if test ! "$output_check" = "$output"
then
    echo "Test failed"
    exit 1
fi

# Test with line num and regex as a range
output="10
11
12
20"
output_check=$(seq 10 20 | ./speed.pl '4,/19/d')
if test ! "$output_check" = "$output"
then
    echo "Test failed"
    exit 1
fi

# Test with line num and line num as range
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
output_check=$(seq 10 20 | ./speed.pl '4,7s/[0-9]/!/g')
if test ! "$output_check" = "$output"
then
    echo "Test failed"
    exit 1
fi

# Test regex and line number as a range
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
output_check=$(seq 10 20 | ./speed.pl '/12/,8s/[0-9]/!/g')
if test ! "$output_check" = "$output"
then
    echo "Test failed"
    exit 1
fi

# Test regex and regex as a range
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
output_check=$(seq 10 20 | ./speed.pl '/.5/,/9$/s/[0-9]/!/g')
if test ! "$output_check" = "$output"
then
    echo "Test failed"
    exit 1
fi

# Test line num and regex as a range
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
output_check=$(seq 10 20 | ./speed.pl '3,/.8/s/[0-9]/!/g')
if test ! "$output_check" = "$output"
then
    echo "Test failed"
    exit 1
fi

echo "Test passed"
exit 0