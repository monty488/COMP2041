#!/usr/bin/perl -w

# subroutine to interpret the given address,
# and extract the commands and the ranges of the command
# from the given address
sub interpret_given_address {
    # Check if the intial address given has a line number range start
    # or a regex to start the range
    if ($address_initial =~ /([0-9]+),(.*)/) {
        $range_start = $1;
        $address = $2;
    } elsif ($address_initial =~ /\/(.*)\/,(.*)/) {
        $range_start_regex = $1;
        $address = $2;
    } else {
        # if there is no range, the address is just sent in as normal
        $address = $address_initial;
    }
    # Check for the delimiter of the s command
    $global = 0;
    $s_delimiter = "/";
    if ($address =~ /s(.)/) {
        $s_delimiter = $1;
    }
    # Check if the address matches the format of the substitute command
    if ($address =~ /s\Q$s_delimiter\E(.*)\Q$s_delimiter\E(.*)\Q$s_delimiter\E(g)?/) {
        # Check for the global flag
        if (defined $3) {
            $regex1 = $1;
            $regex2 = $2;
            $command = 's';
            $global = 1;
        } else {
            $regex1 = $1;
            $regex2 = $2;
            $command = 's';
        }
        # Check if there is a number of lines given to apply to
        if ($address =~ /([0-9]+)s\Q$s_delimiter\E.*/) {
            $line_nums_to_apply = $1;
        
        # Check if the last line indicator is given
        } elsif ($address =~ /\$s\Q$s_delimiter\E.*/) {
            $last_line_address = 1;

        # Check if there is a regex given for the lines to apply to
        } elsif ($address =~ /\/(.*)\/s\Q$s_delimiter\E*/) {
            $regex_lines = $1;
        }
    # Check if the address matches the format of the other commands
    # with a regex given to apply to
    } elsif ($address =~  /\/(.*)\/([qpd])/) {
        if (defined $2) {
            $command = $2;
            $regex1 = $1;
        } else {
            $regex1 = $1;
        }

    # Check if the address just gives number of lines
    # and a command is given
    } elsif ($address =~ /([0-9]+)([qpd])/) {
        $line_num = $1;
        $command = $2;

    # Check if the last line indicator is given
    # and a command is given
    } elsif ($address =~ /\$([qpd])/) {
        $last_line_address = 1;
        $command = $1;
    
    # Check if just a command is given
    } elsif ($address =~ /([qpd])/) {
        $command = $1;

    # Otherwise, output an error because it is an
    # invalid command
    } else {
        print "$0: command line: invalid command\n";
        exit 1;
    }
}

# Subroutine to perform the substituion regex
sub perform_substitution_regex {
    # Set the variables
    my ($r1, $r2, $global_flag, $line) = @_;
    # Check if the global indicator is given
    if ($global_flag == 1) {
        $line =~ s/$r1/$r2/g;
    } else {
        $line =~ s/$r1/$r2/;
    }
    return "$line";
}

# Subroutine to check if the current line
# matches the regex to match
sub check_substitution_regex_match {
    if ($line =~ /$regex1/) {
        return perform_substitution_regex($regex1, $regex2, $global, $line);
    } else {
        return "$line";
    } 
}
# Subroutine to check which case of the substitution command
# has been given and execute it
sub perform_subsitution_command {
    # Check if the range starts with a regex and ends with a regex
    if (defined $range_start_regex and defined $regex_lines) {
        # Check if the range has been met from the given regex
        if ($sub_range_met == 1) {
            # Check if the line matches the regex to start the range
            if ($line =~ /$range_start_regex/) {
                $sub_range_met = 0;
                # Check if the line matches the regex needed to perform the 
                # substitution
                return check_substitution_regex_match();
            } else {
                return "$line";
            }
        } else {
             # Check if the line matches the regex to start the range
            if ($line =~ /$range_start_regex/) {
                # Start the range
                $sub_range_started = 1;
                # Check if the line matches the regex to perform the 
                # substitution
                return check_substitution_regex_match();
            
            # Check if the line matches the regex to end the range
            } elsif ($line =~ /$regex_lines/) {
                # Range has been met
                $sub_range_met = 1;
                return check_substitution_regex_match();

            # Check if the range has started
            } elsif ($sub_range_started == 0) {
                return "$line";
            
            # Check if the range has been met
            } elsif ($sub_range_met == 0) {
                return check_substitution_regex_match();                  
            }
        }
    
    # Check if the range starts with a regex and ends with a line number
    } elsif (defined $range_start_regex and $line_nums_to_apply) {
        # Check if the range has been met
        if ($sub_range_met == 1) {
            # Check if the line matches the regex starting range 
            if ($line =~ /$range_start_regex/) {
                return check_substitution_regex_match();
            } else {
                return "$line";
            }
        } else {
            # Check if the line matches the regex starting range
            if ($line =~ /$range_start_regex/) {
                # Range has started
                $sub_range_started = 1;
                return check_substitution_regex_match();

            # Check if the line is within the current range
            } elsif ($i < $line_nums_to_apply and $sub_range_started) {
                return check_substitution_regex_match();

            # Check if the line is the last line in the ramge
            } elsif ($i == $line_nums_to_apply) {
                # Range has been met
                $sub_range_met = 1;
                return check_substitution_regex_match();
            
            # Check if the range has not started
            } elsif ($sub_range_started == 0) {
                return "$line";
            
            # Check if the range is still active
            } elsif ($sub_range_met == 0) {
                return check_substitution_regex_match();                  
            }               
        }

    # Check if the given range starts with a regex and has a last line indicator    
    } elsif (defined $range_start_regex and defined $last_line_address) {
        # Check if the line matches the regex starting range
        if ($line =~ /$range_start_regex/) {
            # Range has started 
            $sub_range_started = 1;

            return check_substitution_regex_match();

        } else {
            # Check if the range is currently active
            if ($sub_range_started == 1) {
                return check_substitution_regex_match();

            } else {
                return "$line";
            }
        }  
    # Check if the given range starts with a line num and ends with a regex           
    } elsif (defined $range_start and defined $regex_lines) {
        # Check if the current line is at the beginning of the range
        if ($i == $range_start) {
            if ($sub_range_met == 0) {
                return check_substitution_regex_match(); 
            } else {
                return "$line";
            }   
        }      

        # Check if we are still in the range
        if ($i > $range_start) {
            # Check if we have met the end of the range
            if ($line =~ /$regex_lines/) {

                if ($sub_range_met == 0) {
                    $sub_range_met = 1;
                    return check_substitution_regex_match();  
                }

            } else {
                # If range has not been met, continute to check
                # to apply substitution
                if ($sub_range_met == 0) {
                    return check_substitution_regex_match(); 

                } else {
                    return "$line";
                }
            }
        }
        # if not in range, return the line as normal
        if ($i < $range_start) {
            return "$line";
        }

    # Check if the range starts with a line num and ends with a line num
    } elsif (defined $range_start and defined $line_nums_to_apply) {
        # Check if in range, then perform the substitution checks
        if ($i >= $range_start and $i <= $line_nums_to_apply) {
            return check_substitution_regex_match();  

        } else {
            return "$line";
        }
    # Check if the range starts with a line num and ends at the last line
    } elsif (defined $range_start and defined $last_line_address) {

        # Check if the range has begun
        if ($i >= $range_start) {
            return check_substitution_regex_match(); 

        } else {
            return "$line";
        }
    
    # Check if we have only been given a regex to start at
    } elsif (defined $regex_lines) {

        # Check if the line matches that regex
        if ($line =~ /$regex_lines/) {
            perform_substitution_regex($regex1, $regex2, $global, $line);

        } else {
            return "$line";
        }
    # Check if we have only been given lines to apply to
    } elsif (defined $line_nums_to_apply) {

        # Check if reached that line, apply substitution
        if ($line_nums_to_apply == $i) {
            perform_substitution_regex($regex1, $regex2, $global, $line);
        } else {
            return "$line";
        }
    # Check if only given last line indicator
    } elsif (defined $last_line_address) {
        # perform substitution checks until end of file
        if (eof(STDIN)) {
            perform_substitution_regex($regex1, $regex2, $global, $line);
        } else {
            return "$line";
        }
    } else {
        perform_substitution_regex($regex1, $regex2, $global, $line); 
    }
}

# Subroutine to check and perform the
# quit command
sub perform_quit_command {
    my ($line) = @_;
    # Check if a regex to compare to has been given
    if (defined $regex1) {
        # Check if the line matches the regex,
        # quit if it does
        if ($line =~ /$regex1/) {
            return 1;
        } else {
            return 0;     
        }
    } else {
        # Check if we have been given the indicatr
        # for the last line
        if (defined $last_line_address) {
            if (eof(STDIN)) {
                return 1;
            }
        
        # Check if we have been given a line num
        # and check if we have reached that line to quit on
        } elsif (defined $line_num and $line_num == $i) {
            return 1;
        } else {
            return 0;
        }
    }
}

# Subroutine to check and perform 
# the delete command
sub perform_delete_command {
    my ($line) = @_;
    # Check if range given starts with a regex and ends with a line number
    if (defined $range_start_regex and defined $line_num) {
        # Check if the range has met 
        if ($del_range_met == 1) {
            # Check if the line matches the regex to start the range
            if ($line =~ /$range_start_regex/) {
                return 1;
            } else {
                return 0;
            }
        } else {
            # Check if the line matches the regex to start the range
            if ($line =~ /$range_start_regex/) {
                # Range has started
                $del_range_started = 1;
                return 1;
            }
            # Check if we are currently in the range   
            if ($i < $line_num and $del_range_started == 1) {
                return 1;
            }
            # Check if we have met the end of the range
            if ($i == $line_num) {
                $del_range_met = 1;
                return 1;
            }
            # Check if we have not met the range
            if ($del_range_started == 0) {
                return 0;
            }
        }
    # Check if the given range starts with a regex and ends at the last line
    } elsif (defined $range_start_regex and defined $last_line_address) {
        # Check if the current line matches the regex to start the range
        if ($line =~ /$range_start_regex/) {
            $del_range_started = 1;
            return 1;
        } 
        # Check if we are currently in the range
        if ($del_range_started == 1) {
            return 1;
        } else {
            return 0;
        }

    # Check if the given range starts and ends with a regex
    } elsif (defined $range_start_regex and defined $regex1) {
        # Check if the current range has been met
        if ($del_range_met == 1) {
            if ($line =~ /$range_start_regex/) {
                $del_range_met = 0;
                $del_range_started = 1;
                return 1;
            } else {
                return 0;
            }
        } else {
            # Check if the line matches the regex to start the range
            if ($line =~ /$range_start_regex/) {
                # Range has started
                $del_range_started = 1;
                return 1;
            }
            # Check if the line matches the end of the range
            if ($line =~ /$regex1/) {
                $del_range_met = 1;
                $del_range_started = 0;
                return 1;
            } else {
                # Check if the range has started
                if ($del_range_started == 0) {
                    return 0;
                }  else {
                    return 1;
                }         
            }
        }  

    # Check if the range given starts and ends with a line number
    } elsif (defined $range_start and defined $line_num) {
        # Check if we are currently in range
        if ($i >= $range_start and $i <= $line_num) {
           return 1;
        } else {
            return 0;
        }

    # Check if the given range starts at a line and ends at eof
    } elsif (defined $range_start and defined $last_line_address) {
        # Check if range has started
        if ($i >= $range_start) {
            return 1;
        } else {
            return 0;
        }

    # Check if the given range starts at a line num and ends with a regex
    } elsif (defined $range_start and defined $regex1) {
        # Check if we are not in the range
        if ($i < $range_start) {
            return 0;
        }
        # Check if we have met the start of the range
        if ($i == $range_start) {
            return 1;
        }
        # Check we are currenly in the range
        if ($i > $range_start) {
            # Check if the current line matches
            # the regex for the end of the range
            if ($line =~ /$regex1/) {
                # Check if range has been met before
                if ($del_range_met == 1) {
                    return 0;
                } else {
                    $del_range_met = 1;
                    return 1;
                }
            } else {
                if ($del_range_met == 0) {
                    return 1;
                } else {
                    return 0;
                }
                
            }
        }
    # Check if we have just been given a regex
    } elsif (defined $regex1) {
        # if regex matches, delete line
        if ($line =~ /$regex1/) {
            return 1;
        } else {
            return 0;     
        }
    # Check if we are just given indicator to last line
    } elsif (defined $last_line_address) {
        # delete until eof
        if (eof(STDIN)) {
            exit 0;
        } else {
            return 0;
        }
    # Check if only given a line number 
    } elsif (defined $line_num) {
        # if reached that line number, delete it
        if ($line_num == $i) {
            return 1;
        } else {
            return 0;
        }
    } else {
        return 1;
    }
}

# Subroutine to check and perform
# the print command
sub perform_print_command {
    my ($line) = @_;

    # Check if the range starts with a regex and ends with a line number
    if (defined $range_start_regex and defined $line_num) {
        # Check if the range has been met before
        if ($print_range_met == 1) {
            if ($line =~ /$range_start_regex/) {
                return "$line";
            }
        } else {
            # Check if the range has been met
            if ($line =~ /$range_start_regex/) {
                # The range has started
                $print_range_started = 1;
                return "$line";
            
            # Check if we are in the current range
            } elsif ($i < $line_num and $print_range_started) {
                return "$line";
            
            # Check if we have reached the end of the range
            } elsif ($i == $line_num) {
                $print_range_met = 1;
                return "$line";
            }
        }

    # Check if the given range starts with a regex and ends at eof
    } elsif (defined $range_start_regex and defined $last_line_address) {
        # Check if the start of the range has been met
        if ($line =~ /$range_start_regex/) {
            $print_range_started = 1;
            return "$line";
        }

        # Check if we are currently in the range
        if ($print_range_started == 1) {
            return "$line";
        }

    # Check if the given range starts with a regex and ends with a regex
    } elsif (defined $range_start_regex and defined $regex1) {
        # Check if the range has been met before
        if ($print_range_met == 1) {
            if ($line =~ /$range_start_regex/) {
                $print_range_met = 0;
                return "$line";
            }
        } else {
            # Check if the range has started
            if ($line =~ /$range_start_regex/) {
                # Range has started
                $print_range_started = 1;
                return "$line";
            
            # Check if the range has been met
            } elsif ($line =~ /$regex1/) {
                $print_range_met = 1;
                return "$line";
            
            # Check if we are currently in the range
            } elsif ($print_range_met == 0) {
                return "$line";
            }
        }

    # Check if the given range starts and ends with a line number
    } elsif (defined $range_start and defined $line_num) {
        # Check if we are currently in the range
        if ($i >= $range_start and $i <= $line_num) {
            return "$line";
        }

    # Check if the given range starts with a line num ad ends at eof
    } elsif (defined $range_start and defined $last_line_address) {
        # Check if we are in the range
        if ($i >= $range_start) {
            return "$line";
        }

    # Check if the given range starts with a line num and ends with a regex
    } elsif (defined $range_start and defined $regex1) {
        # Check if we have started the range
        if ($i == $range_start) {
            if ($print_range_met == 0) {
                return "$line";
            }   
        }      
        # Check if we are currently in the range
        if ($i > $range_start) {
            # Check if we have met the end of the range
            if ($line =~ /$regex1/) {
                if ($print_range_met == 0) {
                    $print_range_met = 1;
                    return "$line";
                }
            } else {
                # If currently in range, keep printing
                if ($print_range_met == 0) {
                    return "$line";
                }
            }
        }
    # Check if we are given a normal print command
    } elsif (!defined $regex1 and !defined $last_line_address and !defined $line_num) {
        return "$line";

    # Check if we are given a regex to match with the print
    } elsif (defined $regex1) {
        # If regex is matched, print the line
        if ($line =~ /$regex1/) {
            return "$line";
        }
    } else {
        # If last line indicator is given, print until eof
        if (defined $last_line_address) {
            if (eof(STDIN)) {
                return "$line";
            }
        }
        # Check if current line num given with the print command
        # has been reached
        if (defined $line_num and $line_num == $i) {
            return "$line";
        }
    }
}

# Subroutine to reinitialize values that are used
# throughout the program that needs to be reset
# everytime a command has been called
sub reintialize_values_for_loop {
    undef $global;
    undef $s_delimiter;
    undef $regex1;
    undef $regex2;
    undef $command;
    undef $line_nums_to_apply;
    undef $regex_lines;
    undef $line_num;
    undef $last_line_address;
    undef $range_start;
    undef $range_start_regex;

    undef $check;
}

# Subroutine to get commands from
# a given files
sub get_commands_from_files {
    $i = 1;
    while ($i < $length) {
        open my $in, '<', $ARGV[$i] or die "$0: couldn't open file $ARGV[$i]: No such file or directory";
        while ($line = <$in>) {
            if (index($line, ";") != -1) {
                @commands = split(/[;\n]/, $line);
            } else {
                push @commands, $line;
            }          
        }
        close $in;
        $i += 1;
    }
}

$length = @ARGV;

# if the length is 0, print the usage
if ($length == 0) {

    print "usage: $0 [-i] [-n] [-f <script-file> | <sed-command>] [<files>...]\n";
    exit 0;
}

if ($length == 1) {
    # Check if the --help flag is given
    if ($ARGV[0] eq "--help") {
        print "usage: $0 [-i] [-n] [-f <script-file> | <sed-command>] [<files>...]\n";
        exit 0;
    }

    # Check the address given, and grab
    # multiple commands if there is more than one
    $address = shift @ARGV;
    if (index($address, ";") != -1) {
        @commands = split(/[;\n]/, $address);
    } else {
        push @commands, $address;
    }  

} elsif ($length >= 2) {
    # Check if the -n flag is given
    if ($ARGV[0] eq "-n") {
        $n_flag = shift @ARGV;

        # Check if the -f flag is given
        if ($ARGV[0] eq "-f") {
            # run subroutine to get the commands from the files
            get_commands_from_files()

        } else {
            # Check the address given, and grab
            # multiple commands if there is more than one
            $address = shift @ARGV;

            if (index($address, ";") != -1) {
                @commands = split(/[;\n]/, $address);  
            } else {
                push @commands, $address;
            }
        }
    
    # If just the -f flag is given,
    # get the commands via the subroutine
    } elsif ($ARGV[0] eq "-f") {
        get_commands_from_files() 

    } else {
        
        # Check the address given, and grab
        # multiple commands if there is more than one
        $address = shift @ARGV;
        if (index($address, ";") != -1) {
            @commands = split(/[;\n]/, $address);
        } else {
            push @commands, $address;
        }              
    }
    
}

# Initialize variables that are used in each
# of the commands' subroutines
$print_range_started = 0;
$print_range_met = 0;
$sub_range_started = 0;
$sub_range_met = 0;
$del_range_started = 0;
$del_range_met = 0;
$i = 1;

while ($line = <STDIN>) {
    $skip_line = 0;
    $exit_flag = 0;
    # Loop through each given command for each line
    foreach $address_initial (@commands) {
        # Interpret the address to obtain
        # the commands
        interpret_given_address();
        if ($command eq 'q') {
            # run function to perform quit command
            $check = perform_quit_command($line);
            # if 1 is returned, quit the program
            if ($check == 1) {
                $exit_flag = 1;
                $line_to_print = $line;
            } else {
                if (!defined $n_flag) {
                    # print if -n is not given
                    $line_to_print = $line; 
                }
                             
            }
        }
        if ($command eq 'd') {
            # run function to perform delete command
            $check = perform_delete_command($line);
            # if delete returns 1, delete the line
            # by skipping the loop for this line
            if ($check == 1) {
                $i += 1;
                $skip_line = 1;
                last;
            }
            if ($check == 0) {
                if (!defined $n_flag) {
                    # print if -n is not given
                    $line_to_print = $line;
                }
            }
        }
        if ($command eq 'p') {
            if (!defined $n_flag) {
                # print if -n is not given
                print "$line";
            }
            # run function to perform print command
            $check = perform_print_command($line);
            if (defined $check) {
                $line_to_print = $check;
                $line = $line_to_print;

            }
        }
        if ($command eq 's') {
            # run function to perform print command
            $check = perform_subsitution_command($line);
            if (defined $check) {
                if (!defined $n_flag) {
                    $line_to_print = $check;
                    $line = $line_to_print;
                }
            }
        }
        # run function to reset variables
        # for the command
        reintialize_values_for_loop();
    }
    # check exit flag from quit function
    if ($exit_flag == 1) {
        print $line_to_print;
        exit 0;
    }
    # check skip flag from delete command
    if ($skip_line == 1) {
        next;
    }
    # print the line if needed
    if (defined $line_to_print) {
        print "$line_to_print";
        undef $line_to_print;
    }
    $i += 1;
}
