#!/bin/dash

# This test will check to see if command files
# given to speed.pl function correctly

# Make a temporary file to store commands
tmp_file=$(mktemp tmp.XXXXXXXXXX)
trap 'rm -rf $tmp_file; exit' INT TERM EXIT

# Test if file with two commands separated with a
# semicolon can function 
echo "3,4d;p" > $tmp_file

output="10
11
14
15
16
17
18
19
20"
output_check=$(seq 10 20 | ./speed.pl -n -f $tmp_file)
if test ! "$output_check" = "$output"
then
    echo "Test failed"
    exit 1
fi

# Test if file with multiple commands separated with a
# semicolon can function 
echo '1,5d;9,12d;20,25d' > $tmp_file

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
output_check=$(seq 10 30 | ./speed.pl -f $tmp_file)
if test ! "$output_check" = "$output"
then
    echo "Test failed"
    exit 1
fi

# Test if file with multiple commands separated by a 
# new line can function
echo "1,10s/[0-9]/-/g" > $tmp_file
echo "11,20s/[0-9]/h/g" >> $tmp_file
echo "21,30s/[0-9]/j/g" >> $tmp_file

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
output_check=$(seq 1 30 | ./speed.pl -f $tmp_file)
if test ! "$output_check" = "$output"
then
    echo "Test failed"
    exit 1
fi

# Test if two commands separated by a newline can function
echo '4,/17/d' > $tmp_file
echo '/20/,/21/s/[0-9]/j/g' >> $tmp_file

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
output_check=$(seq 10 30 | 2041 speed -f $tmp_file)
if test ! "$output_check" = "$output"
then
    echo "Test failed"
    exit 1
fi

# Test if multiple commands separated by a semicolon in a file
# can function
echo "4,/17/d;10,15s/[0-9]/j/g;/25/s/[0-9]/h/g;/29/,/30/d" > $tmp_file

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
output_check=$(seq 10 30 | 2041 speed -f $tmp_file)
if test ! "$output_check" = "$output"
then
    echo "Test failed"
    exit 1
fi


echo "Test passed"
exit 0