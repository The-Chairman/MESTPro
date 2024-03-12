designsourcesdir = design_sources
designobjs =$(foreach o,  mest_pro_memory.v mest_pro_output.v mest_pro.sv mest_pro_ctrlr.sv mest_pro_decode.sv mest_pro_exec.sv mest_pro_fetch.sv mest_pro_rom.sv program_rom.v, $(realpath $(designsourcesdir)/$(o)))

simsourcesdir = simulation_sources
simobjs = $(foreach o, mest_pro_STIM.sv mest_pro_tb.sv, $(realpath $(simsourcesdir)/$(o) ) )

programdir = program_files
progfile = $(programdir)/prog3.mem

fvdir = functional_verification
fvobjs = $(foreach o, test_pre presynthesis.vcd, $(fvdir)/$(o) )

syndir = synthesis_gens

postsyndir = post_synthesis
postsynsimobjs = $(foreach o, mest_pro_STIM.sv mest_pro_tb.sv, $(realpath $(simsourcesdir)/$(o) ) )


define VMACROS =
DUMP_FILE=`"$(abspath $(syndir)/synthesis.vcd)`"
ROM_FILE=`"$(abspath $(progfile))`"
ROM_SIZE=$(shell wc -l $(progfile) | awk -F' ' '{print $$1}')
endef

export VMACROS

# Functions? ###################################################################

all:	functional-verification synthesis


.PHONY: functional-verification waveform synthesis post-synthesis-sim\
 clean mtest

# functional-verification targets ##############################################
functional-verification: $(fvdir) $(fvobjs)
	
$(fvdir)/test_pre:	$(designobjs) $(simobjs)
	iverilog -g2005-sv -o $@ -I $(designsourcesdir) \
	-DDUMP_FILE=\`\"$(abspath $(fvdir)/presynthesis.vcd)\`\" \
	-DROM_FILE=\`\"$(abspath $(programdir)/prog3.mem)\`\" \
	-DROM_SIZE=`wc -l $(programdir)/prog3.mem | awk -F' ' '{print $$1}'` \
	$(designobjs) $(simobjs)

$(fvdir)/presynthesis.vcd: $(fvdir)/test_pre
	cd $(fvdir); vvp -M../ -N test_pre -s
	
waveform:	$(fvdir)/presynthesis.vcd
	cd $(fvdir); gtkwave ./presynthesis.vcd presynthesis.gtkw &

# synthesis targets ############################################################
synthesis: $(syndir) $(syndir)/rom_synth.v

	
$(syndir)/rom_synth.v: $(designobjs) $(simobjs)
	$(eval temp_macro_file=$(shell mktemp $(syndir)/XXXX.macro ) )
	echo "$$VMACROS" > $(temp_macro_file)
	export SYNTH_FILE="$@" BUILD_FILES="$(designobjs)" \
	VMACROS_FILE="$(strip $(temp_macro_file))" TOP_MODULE=mest_pro; \
	yosys -c yosys_build.tcl
	rm -f $(temp_macro_file)

# post synthesis targets #######################################################
post-synthesis-sim: $(postsyndir) $(syndir)/rom_synth.v
	iverilog  -g2005-sv -o $(l)/test_post -D POST_SYNTHESIS -I $(designsourcesdir) \
	-DDUMP_FILE=\`\"$(abspath $(postsyndir)/postsynthesis.vcd)\`\" \
	-DROM_FILE=\`\"$(abspath $(programdir)/prog3.mem)\`\" \
	-DROM_SIZE=`wc -l $(programdir)/prog3.mem | awk -F' ' '{print $$1}'` \
	-s mest_pro_tb $(syndir)/rom_synth.v $(postsynsimobjs)
	
# directory targets ############################################################
$(fvdir) $(syndir) $(postsyndir):
	mkdir -p $@
	
clean:
	rm -f $(fvdir)/test_pre
	rm -f $(fvdir)/presynthesis.vcd
	rm -f test_rom_synth.v
	rm -f $(syndir)/*.macro
	rm -f $(syndir)/rom_synth.v
	
mtest:
		echo $(designobjs)
		echo $(simobjs)
		echo $(VMACROS)
