#!/bin/dash


# This test will check that the $ address is used correctly
# for subset 1

# Test $ with substitute
output="100
150
200
250
300
350
400
450
500
550
600
6!0"
output_check=$(seq 100 50 650 | ./speed.pl '$s/5/!/g')
if test ! "$output_check" = "$output"
then
    echo "Test failed"
    exit 1
fi

# Test $ with delete
output="10
20
30
40
50
60
70
80
90"
output_check=$(seq 10 10 100 | ./speed.pl '$d')
if test ! "$output_check" = "$output"
then
    echo "Test failed"
    exit 1
fi

# Test $ with print
output="10
20
30
40
50
60
70
80
90
100
100"
output_check=$(seq 10 10 100 | ./speed.pl '$p')
if test ! "$output_check" = "$output"
then
    echo "Test failed"
    exit 1
fi

# Test $ with print and -n
output="100"
output_check=$(seq 10 10 100 | ./speed.pl -n '$p')
if test ! "$output_check" = "$output"
then
    echo "Test failed"
    exit 1
fi


output="10
20
30
40
50
60
70
80
90
100"
output_check=$(seq 10 10 100 | ./speed.pl '$q')
if test ! "$output_check" = "$output"
then
    echo "Test failed"
    exit 1
fi

echo "Test passed"
exit 0