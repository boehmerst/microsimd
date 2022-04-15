####################################################################################################################################
## Author: Stephan Böhmer, 2010
#####################################################################################################################################
TARGET = image
TARGET_TYPE = $(TARGET)

INCLUDES = 
MODULES  = app startup


#Directories
DIR_SRC  = src
DIR_OBJ  = $(TARGET_TYPE)/obj
DIR_IMG  = $(TARGET_TYPE)/img
DIR_BIN  = $(TARGET_TYPE)/img
DIR_LIB  = $(TARGET_TYPE)/lib
DIR_INFO = $(TARGET_TYPE)/info
DIR_DEP  = $(TARGET_TYPE)/dep
DIR_DOC  = doc


#File extensions
EXT_LIB  = lib
EXT_IMG  = elf
EXT_BIN  = bin
EXT_CPP  = cpp
EXT_C    = c
EXT_S    = S
EXT_O    = o
EXT_H    = h
EXT_DEP  = dep
EXT_MEM  = mem


#just do prevent confusion:
EXT_OBJ  := $(EXT_O)
EXT_AXF  := $(EXT_IMG)


#Compile time configuration symbols
ENABLE_TRACES   = 1
TRACE_LEVEL_APP = TRACE_LEVEL_INFO
TRACE_LEVEL_SYS = TRACE_LEVEL_INFO
TRACE_LEVEL_DRV = TRACE_LEVEL_INFO


#Build info
BUILD_INFO_C  = $(DIR_SRC)/build_info.$(EXT_C)
BUILD_INFO_O  = $(DIR_OBJ)/build_info.$(EXT_O)
BUILD_DATE    := $(shell date "+%m-%d-%Y")
BUILD_TIME    := $(shell date "+%H:%M:%S")


#Headers
#generates a list of all header files in the include and module directories
HEADERS       = $(wildcard $(addprefix $(DIR_SRC)/,$(addsuffix /*.$(EXT_H),$(MODULES)))) $(wildcard $(addsuffix /*.$(EXT_H),$(INCLUDES)))


#Sources (computed from MODULES)
#produces a file list by searching the module directories for source files
SOURCES_CPP   = $(wildcard $(addprefix $(DIR_SRC)/,$(addsuffix /*.$(EXT_CPP),$(MODULES))))
SOURCES_C     = $(wildcard $(addprefix $(DIR_SRC)/,$(addsuffix /*.$(EXT_C),$(MODULES))))
SOURCES_S     = $(wildcard $(addprefix $(DIR_SRC)/,$(addsuffix /*.$(EXT_S),$(MODULES))))


#Objects (computed from MODULES)
#removes the DIR_SRC path, changes the extension to ".o", and adds "obj/"
OBJECTS_CPP   = $(addprefix $(DIR_OBJ)/,$(patsubst %.$(EXT_CPP),%.$(EXT_O),$(patsubst $(DIR_SRC)/%,%,$(SOURCES_CPP))))
OBJECTS_C     = $(addprefix $(DIR_OBJ)/,$(patsubst %.$(EXT_C),%.$(EXT_O),$(patsubst $(DIR_SRC)/%,%,$(SOURCES_C))))
OBJECTS_S     = $(addprefix $(DIR_OBJ)/,$(patsubst %.$(EXT_S),%.$(EXT_O),$(patsubst $(DIR_SRC)/%,%,$(SOURCES_S))))


# image options
BINARY = $(addsuffix .$(EXT_BIN), $(TARGET))
IMAGE  = $(addsuffix .$(EXT_IMG), $(TARGET))

B_IMG  = $(DIR_BIN)/$(BINARY)
L_IMG  = $(DIR_IMG)/$(IMAGE)


# MCU name and submodel
MCU      = v7.00.a
SUBMDL   = 


# Place -I options here
CINCS = $(addprefix -I$(DIR_SRC)/,$(INCLUDES)) $(addprefix -I,$(DIR_SRC)) \
  $(addprefix -I,include)


# Output format. (can be ihex, srec or binary)
FORMAT = binary


# Optimization level, can be [0, 1, 2, 3, s]. 
OPT = 0


# Define Messages
MSG_IMAGE 						= Creating Image.................
MSG_EXTENDED_LISTING 	= Creating Extended Listing......
MSG_SYMBOL_TABLE			= Creating Symbol Table..........
MSG_LINKING 					= Linking........................
MSG_COMPILING 				= Compiling C....................
MSG_COMPILINGCPP 			= Compiling C++..................
MSG_ASSEMBLING 				= Assembling.....................
MSG_CLEANING 					= Removing files
MSG_FORMATERROR 			= Can not handle output-format...
MSG_DONE							= Done
MSG_BUILD_INFO        = Creating Build-Info............


# Define all object files.
COBJ   = $(OBJECTS_C)
AOBJ   = $(OBJECTS_S)
CPPOBJ = $(OBJECTS_CPP)
	
	
# Define all listing files.
LST = $(ASRC:.S=.lst) $(ASRCARM:.S=.lst) $(SRC:.c=.lst) $(SRCARM:.c=.lst)
LST += $(CPPSRC:.cpp=.lst) $(CPPSRCARM:.cpp=.lst)


# Compiler flags to generate dependency files.
GENDEPFLAGS = -MD -MP -MF $(DIR_DEP)/$(@F).dep


# Define commands for conditional directory creation
CMD_OBJ_DIR  = @mkdir -p $(patsubst src/%,%,$(dir $@))
CMD_DEP_DIR  = @mkdir -p $(DIR_DEP)
CMD_IMG_DIR  = @mkdir -p $(DIR_IMG)
CMD_INFO_DIR = @mkdir -p $(DIR_INFO)


# Executable file definitions 
elf = $(addprefix $(DIR_IMG)/,$(TARGET).elf)
bin = $(addprefix $(DIR_IMG)/,$(TARGET).bin)
hex = $(addprefix $(DIR_IMG)/,$(TARGET).hex)

lss = $(addprefix $(DIR_INFO)/,$(TARGET).lss) 
sym = $(addprefix $(DIR_INFO)/,$(TARGET).sym)


# The gcc compiler and linker
#SHELL 	= cmd.exe
C        = mb-gcc
CC       = mb-g++
ASM      = mb-as
LINK     = mb-g++

OBJCOPY  = mb-objcopy
OBJDUMP  = mb-objdump
SIZE 	   = mb-size
NM 		   = mb-nm

BIN2MEM4 = sw/util/bin2mem4
BIN2MEM  = sw/util/bin2mem

REMOVE   = rm -f
COPY     = cp

#these flags are just to keep in mind they exist ;-)
EXTRA_LINKER_FLAGS = -lc -lgcc -lstdc++ --gc-sections

DFLAGS = -D ENABLE_TRACES=$(ENABLE_TRACES)                                     \
         -D TRACE_LEVEL_APP=$(TRACE_LEVEL_APP)                                 \
	       -D TRACE_LEVEL_SYS=$(TRACE_LEVEL_SYS)                                 \
	       -D TRACE_LEVEL_DRV=$(TRACE_LEVEL_DRV)

CFLAGS = -c -std=c99 -mcpu=$(MCU) -mno-xl-soft-mul -mxl-barrel-shift -mno-xl-pattern-compare     \
  -O$(OPT) -Wall $(DFLAGS) -o$@

CCFLAGS = -c -mcpu=$(MCU) -O$(OPT) -fno-rtti -fno-exceptions -Wall             \
  -mno-xl-soft-mul -mxl-barrel-shift -mno-xl-pattern-compare -Wno-invalid-offsetof $(DFLAGS) -o $@

#ASMFLAGS = -mcpu=$(MCU) -o $@
ASMFLAGS = -o $@

#LINKFLAGS = -T xilinx.ld -o $@ -Wl,-Map,$(DIR_INFO)/$(TARGET).map,--cref -lm -L./lib -lxil
#LINKFLAGS = -T xilinx.ld -o $@ -Wl,-Map,$(DIR_INFO)/$(TARGET).map,--cref -nostdlib -Wl,-defsym -Wl,_TEXT_START_ADDR=0x0000

LINKFLAGS = -T xilinx.ld -o $@ -Wl,-Map,$(DIR_INFO)/$(TARGET).map,--cref -nostdlib

# Default target.
all: build

ifeq ($(FORMAT),ihex)
build: $(elf) $(hex) $(lss) $(sym)
else 
ifeq ($(FORMAT),binary)
build: $(elf) $(bin) $(lss) $(sym)
else 
$(error "$(MSG_FORMATERROR) $(FORMAT)")
endif
endif


# Display size of file.
ELFSIZE = $(SIZE) $(elf)
size:
	@$(ELFSIZE)

# Create final output file (.hex) from ELF output file.
$(hex): $(elf)
	@echo $(MSG_FLASH) $@
	@$(OBJCOPY) -O $(FORMAT) $< $@
	
# Create final output file (.bin) from ELF output file.
$(bin): $(elf)
	@echo $(MSG_IMAGE) $@
	@$(OBJCOPY) -O $(FORMAT) $< $@
	@$(BIN2MEM) < $(bin) > rom.mem
	@$(BIN2MEM4) < $(bin)
	@mv *$(EXT_MEM) $(DIR_IMG)


# Create extended listing file from ELF output file. testing: option -C
$(lss): $(elf)
	@echo $(MSG_EXTENDED_LISTING) $@
	@$(OBJDUMP) -h -S -C $< > $@


# Create a symbol table from ELF output file.
$(sym): $(elf)
	@echo $(MSG_SYMBOL_TABLE) $@
	@$(NM) -n $< > $@
	@echo $(MSG_DONE)


# Link: create ELF output file from object files.
.SECONDARY : $(TARGET).elf
.PRECIOUS : $(AOBJ) $(COBJ) $(CPPOBJ)
$(elf):  $(AOBJ) $(COBJ) $(CPPOBJ) $(BUILD_INFO_O)
	@echo $(MSG_LINKING) $@
	$(CMD_IMG_DIR)
	$(CMD_INFO_DIR)
	@$(LINK) $(AOBJ) $(COBJ) $(CPPOBJ) $(BUILD_INFO_O) $(LINKFLAGS)

	

# Compile: create object files from C source files.
$(COBJ) : $(DIR_OBJ)/%.$(EXT_O) : $(DIR_SRC)/%.$(EXT_C)
	@echo $(MSG_COMPILING) $<
	$(CMD_OBJ_DIR)
	$(CMD_DEP_DIR)
	@$(C) $(CFLAGS) $(GENDEPFLAGS) $(CINCS) $< 



# Compile: create object files from C++ source files.
$(CPPOBJ) : $(DIR_OBJ)/%.$(EXT_O) : $(DIR_SRC)/%.$(EXT_CPP)
	@echo $(MSG_COMPILINGCPP) $<
	$(CMD_OBJ_DIR)
	$(CMD_DEP_DIR)
	@$(CC) $(CCFLAGS) $(GENDEPFLAGS) $(CINCS) $< 



# Assemble: create object files from assembler source files.
$(AOBJ) : $(DIR_OBJ)/%.$(EXT_O) : $(DIR_SRC)/%.$(EXT_S)
	@echo $(MSG_ASSEMBLING) $<
	$(CMD_OBJ_DIR)
	@$(ASM) $(ASMFLAGS) $<
	


#Compile Build Info
#.PHONY : $(BUILD_INFO_O)
$(BUILD_INFO_O) : $(BUILD_INFO_C)
	@echo $(MSG_COMPILING) $<
	@$(C) $(CFLAGS) $(BUILD_INFO_C) -o $(BUILD_INFO_O) 


  
.PHONY : $(BUILD_INFO_C)
$(BUILD_INFO_C) :
	@echo $(MSG_BUILD_INFO) $@
	@printf "//automatic generated, do not edit\nconst char* GLOBAL_BUILD_DATE=\"%b\";\nconst char* GLOBAL_BUILD_TIME=\"%b\";\n" "$(BUILD_DATE)" "$(BUILD_TIME)" > $(BUILD_INFO_C)


dummy :
	@echo "INC" $(wildcard $(addprefix $(DIR_DEP)/,*.o.d))


# Target: clean project.
clean :
	@echo $(MSG_CLEANING)
	@$(REMOVE) -r image/*

# Include the dependency files.
-include   $(wildcard $(addprefix $(DIR_DEP)/,*.o.dep)) --no-warning


# Listing of phony targets.
.PHONY : all size build clean done dummy
