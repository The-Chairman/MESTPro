PROGRAM_RUNS_DIR = program_runs
PROGRAM_DIR = program_files
PROGRAM_SOURCES := $(wildcard $(PROGRAM_DIR)/*.asm)
PROGRAM_OBJECTS := $(patsubst $(PROGRAM_DIR)/%.asm, $(PROGRAM_DIR)/%.mem, $(PROGRAM_SOURCES))
PROGRAM_RUNS := $(sort $(basename $(notdir $(PROGRAM_SOURCES))))

define PROJ_RULE
$(1)-$(2):
	$(MAKE) -f synthesis.mak  build_dir=$(PROGRAM_RUNS_DIR)/$1  prog_file=$(PROGRAM_DIR)/$1.mem $2
endef

SYNTHESIS_RULES=all functional-verification functional-waveform synthesis \
	post-synthesis-sim synthesis-waveform clean mtest stats

$(foreach _rule, $(SYNTHESIS_RULES), \
	$(foreach _proj, $(PROGRAM_RUNS), \
		$(eval $(call PROJ_RULE,$(_proj),$(_rule)))))

# Functions? ###################################################################

.PHONY: $(PROGRAM_RUNS) build_all clean_all stats_all

build_all: $(PROGRAM_RUNS)

clean_all: $(foreach _proj, $(PROGRAM_RUNS), $(_proj)-clean)

stats_all: $(foreach _proj, $(PROGRAM_RUNS), $(_proj)-stats)

$(PROGRAM_RUNS):
	$(MAKE) -f synthesis.mak \
		prog_file=$(PROGRAM_DIR)/$(shell basename $@).mem \
		build_dir=$(PROGRAM_RUNS_DIR)/$@ \
		all