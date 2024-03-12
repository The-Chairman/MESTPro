if {[info exists ::env(SYNTH_FILE)]} { 
	set synth_file $env(SYNTH_FILE) 
} else { 
	set synth_file "test_rom_synth.v"
}
if {[info exists ::env(VMACROS_FILE)]} { 
	set vmacros_file $env(VMACROS_FILE) 
} else { 
	set vmacros_file ""
}
if {[info exists ::env(TOP_MODULE)]} { 
	set TOP_MODULE $env(TOP_MODULE) 
} else { 
	set TOP_MODULE ""
}

yosys -import

set fp [ open $vmacros_file r ]
set file_data [read $fp ]
close $fp
set data [split $file_data "\n" ]

foreach m $data {
	if { $m ne {} } {
		verilog_defaults -add -D $m
	}
}
#set build_files split $env(BUILD_FILES)

foreach c [lsearch -all -inline -not -exact [split $env(BUILD_FILES)] {}] {
	read_verilog -sv $c
}

synth -top $TOP_MODULE
#difflibmap -liberty mycells.lib
#abc -liberty mycells.lib
clean 

#proc

memory -nomap
#memory_map program_rom %n
#techmap
#simplemap
#synth


write_verilog $synth_file
#write_blif test_rom.blif

