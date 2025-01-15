ifndef prog_file
$(error prog_file is not defined, set it as an env var, or pass it as a parameter to make)
endif

define NEWLINE


endef
build_dir := $(if $(build_dir), $(build_dir), .)
program_dir := $(if $(program_dir), $(program_dir), program_files)

designsourcesdir = design_sources
designobjs =$(foreach o,  mest_pro_memory.v mest_pro_output.v mest_pro.sv \
	mest_pro_ctrlr.sv mest_pro_decode.sv mest_pro_exec.sv mest_pro_fetch.sv \
	mest_pro_rom.sv program_rom.v rom_ctrl.v , $(realpath $(designsourcesdir)/$(o)))

simsourcesdir = simulation_sources
simobjs = $(foreach o, mest_pro_STIM.sv mest_pro_tb.sv rom.sv, $(realpath $(simsourcesdir)/$(o) ) )

prog_size = $(shell wc -l $(prog_file) | awk -F' ' '{print $$1}')

fvdir = $(addprefix $(build_dir)/, functional_verification )
fvobjs = $(foreach o, test_pre presynthesis.vcd presynthesis.json presynthesis.dot, $(fvdir)/$(o) )
syndir = $(addprefix $(build_dir)/, synthesis_gens)

postsyndir = $(addprefix $(build_dir)/, post_synthesis)
postsynsimobjs = $(foreach o, mest_pro_STIM.sv mest_pro_tb.sv, $(realpath $(simsourcesdir)/$(o) ) )

all: $(build_dir) functional-verification synthesis post-synthesis-sim
	bash bin/log_stats.sh $(build_dir)	

.PHONY: functional-verification functional-waveform synthesis \
		post-synthesis-sim synthesis-waveform clean mtest stats errors

$(program_dir)/%.mem: $(program_dir)/%.asm
	python3 ./bin/parse_mest_program.py -c -o $@ $<

# functional-verification targets ##############################################
functional-verification: $(fvdir) $(fvobjs)
	
$(fvdir)/test_pre:	$(designobjs) $(simobjs) $(prog_file)
	iverilog -g2012 -o $@ -I $(designsourcesdir) \
	-DDUMP_FILE=\`\"$(abspath $(fvdir)/presynthesis.vcd)\`\" \
	-DROM_FILE=\`\"$(abspath $(prog_file))\`\" \
	-DROM_SIZE=$(prog_size) \
	$(foreach f,$(designobjs) $(simobjs),$f \$(NEWLINE)) 2> $(fvdir)/test_pre.error > $(fvdir)/test_pre.log 

$(fvdir)/presynthesis.json $(fvdir)/presynthesis.dot:
	touch $@
#	@yosys \
		-p "verilog_defaults -add -D ROM_FILE=\`\"$(abspath $(prog_file))\`\"" \
		-p "verilog_defaults -add -D ROM_SIZE=$(shell wc -l $(abspath $(prog_file)) | awk -F' ' '{print $$1}')" \
		$(foreach cv, $(designobjs) , -p "read_verilog  -sv $(cv)") \
		-p "proc" \
		-p "show -prefix $(fvdir)/presynthesis -notitle -colors 2 -width -format dot " \
		-p "write_json $(fvdir)/presynthesis.json"




$(fvdir)/presynthesis.vcd:
	cd $(fvdir); vvp -M../ -N test_pre 2> ./presynthesis.vcd.error > ./presynthesis.vcd.log
	
functional-waveform:	$(fvdir)/presynthesis.vcd
	cd $(fvdir) && gtkwave ./presynthesis.vcd `[ -f waveform_config.gtkw ] && echo "waveform_config.gtkw" || echo ""`&

# synthesis targets ############################################################
synthesis: $(syndir) $(syndir)/rom_synth.v


$(syndir)/rom_synth.v: $(designobjs) $(simobjs) $(prog_file)
	$(eval temp_macro_file=$(shell mktemp $(syndir)/XXXX.macro ) )
	bash ./bin/vmacros.sh $(abspath $(syndir)/synthesis.vcd) $(abspath $(prog_file)) | tee $(temp_macro_file)
	@echo "MACRO FILE: $(temp_macro_file)"
	@cat $(temp_macro_file)
	export SYNTH_FILE="$@" BUILD_FILES="$(designobjs)" \
	VMACROS_FILE="$(strip $(temp_macro_file))" TOP_MODULE=mest_pro; \
	yosys -q -c yosys_build.tcl -g -l $(syndir)/yosys.log 2> $(syndir)/yosys_build.error
	rm -f $(temp_macro_file)

# post synthesis targets #######################################################
post-synthesis-sim: $(postsyndir) $(postsyndir)/test_post \
					$(postsyndir)/postsynthesis.vcd

$(postsyndir)/test_post: $(syndir)/rom_synth.v  $(prog_file)
	iverilog  -g2012 -o $@ -D POST_SYNTHESIS -I $(designsourcesdir) \
	-DDUMP_FILE=\`\"$(abspath $(postsyndir)/postsynthesis.vcd)\`\" \
	-DROM_FILE=\`\"$(abspath $(prog_file))\`\" \
	-DROM_SIZE=$(prog_size) \
	-s mest_pro_tb $(syndir)/rom_synth.v $(postsynsimobjs)

$(postsyndir)/postsynthesis.vcd: $(postsyndir)/test_post
	cd $(postsyndir); vvp -M../ -N test_post 2> ./postsynthesis.vcd.error > ./postsynthesis.vcd.log

synthesis-waveform: $(postsyndir)/postsynthesis.vcd
	cd $(postsyndir) && gtkwave ./postsynthesis.vcd `[ -f waveform_config.gtkw ] && echo "waveform_config.gtkw" || echo ""`&

# directory targets ############################################################
$(fvdir) $(syndir) $(postsyndir) $(build_dir):
	mkdir -p $@

# Stats #######################################################################
stats:
	$(foreach _dir, $(fvdir) $(syndir) $(postsyndir), @bash ./bin/log_stats.sh $(_dir); echo $(NEWLINE)$(NEWLINE))

errors:
	@printf "= Errors =======================================================\n"
	@for cur_dir in $(fvdir) $(syndir) $(postsyndir); do \
		find "$$cur_dir" -name *.error -print -exec cat '{}' \; ; \
	done;
clean:
	rm -f $(fvdir)/test_pre
	rm -f $(fvdir)/*.log
	rm -f $(fvdir)/*.error
	rm -f $(fvdir)/presynthesis.vcd
	rm -f $(fvdir)/*.json
	rm -f $(fvdir)/*.dot
	rm -f test_rom_synth.v
	rm -f $(syndir)/*.macro
	rm -f $(syndir)/rom_synth.v
	rm -f $(syndir)/*.log
	rm -f $(syndir)/*.error
	rm -f $(postsyndir)/postsynthesis.vcd
	rm -f $(postsyndir)/test_post
	rm -f $(postsyndir)/*.log
	rm -f $(postsyndir)/*.error

mtest:
	$(info $(designobjs))
	$(info $(simobjs))