#!/bin/dash

# This test will check to see if the multiple commands
# given to speed.pl function correctly

# Test if two commands can function
output="10
11
14
15
16
17
18
19
20"
output_check=$(seq 10 20 | ./speed.pl -n '3,4d;p')
if test ! "$output_check" = "$output"
then
    echo "Test failed"
    exit 1
fi

# Test if multiple commands can function
output="15
16
17
22
23
24
25
26
27
28"
output_check=$(seq 10 30 | ./speed.pl '1,5d;9,12d;20,25d')
if test ! "$output_check" = "$output"
then
    echo "Test failed"
    exit 1
fi

# Test if multiple different commands
# can function
output="-
-
-
-
-
-
-
-
-
--
hh
hh
hh
hh
hh
hh
hh
hh
hh
hh
jj
jj
jj
jj
jj
jj
jj
jj
jj
jj"
output_check=$(seq 1 30 | ./speed.pl '1,10s/[0-9]/-/g;11,20s/[0-9]/h/g;21,30s/[0-9]/j/g')
if test ! "$output_check" = "$output"
then
    echo "Test failed"
    exit 1
fi

# Test if multiple commands can function
output="10
11
12
18
19
jj
jj
22
23
24
25
26
27
28
29
30"
output_check=$(seq 10 30 | 2041 speed '4,/17/d;/20/,/21/s/[0-9]/j/g')
if test ! "$output_check" = "$output"
then
    echo "Test failed"
    exit 1
fi

# Test if multiple commands keep function
output="10
11
12
18
jj
jj
jj
jj
jj
jj
hh
26
27
28"
output_check=$(seq 10 30 | ./speed.pl '4,/17/d;10,15s/[0-9]/j/g;/25/s/[0-9]/h/g;/29/,/30/d')
if test ! "$output_check" = "$output"
then
    echo "Test failed"
    exit 1
fi

echo "Test passed"
exit 0