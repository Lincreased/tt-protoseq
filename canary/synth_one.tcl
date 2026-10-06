# Synthesize one canary in Vivado non-project mode. Commands and flags: verify in your version.
# Usage:
#   vivado -mode batch -nojournal -log <log> -source synth_one.tcl -tclargs <top> <default|sv> <part> <file> [<file> ...]
#   default: read_verilog without -sv (Vivado decides how to treat .v and .sv by itself)
#   sv:      read_verilog -sv for every file
# The last line of the log is "CANARY_RESULT <top> <mode> PASS" or "... FAIL: <message>".

if {[llength $argv] < 4} {
    puts "CANARY_RESULT usage: <top> <default|sv> <part> <file> \[<file> ...\]"
    exit 2
}

set top   [lindex $argv 0]
set mode  [lindex $argv 1]
set part  [lindex $argv 2]
set files [lrange $argv 3 end]

if {[catch {
    foreach f $files {
        if {$mode eq "sv"} {
            read_verilog -sv $f
        } else {
            read_verilog $f
        }
    }
    synth_design -top $top -part $part
} err]} {
    puts "CANARY_RESULT $top $mode FAIL: $err"
    exit 1
}

puts "CANARY_RESULT $top $mode PASS"
exit 0
