# Allen Wild's mbed LPC1768 Makefile


GCC_BIN  = /opt/gcc-arm-none-eabi/bin
PROJECT  = LPC1114ISP
PLATFORM = LPC1768
OBJDIR   = build

CPPSOURCES = $(wildcard *.cpp)
CPPOBJECTS = $(patsubst %.cpp, $(OBJDIR)/%.o, $(CPPSOURCES))

OBJECTS		= $(CPPOBJECTS)
SYS_OBJECTS = ./mbed/TARGET_LPC1768/TOOLCHAIN_GCC_ARM/board.o \
			  ./mbed/TARGET_LPC1768/TOOLCHAIN_GCC_ARM/cmsis_nvic.o \
			  ./mbed/TARGET_LPC1768/TOOLCHAIN_GCC_ARM/retarget.o \
			  ./mbed/TARGET_LPC1768/TOOLCHAIN_GCC_ARM/startup_LPC17xx.o \
			  ./mbed/TARGET_LPC1768/TOOLCHAIN_GCC_ARM/system_LPC17xx.o 

PROBJ	= $(OBJDIR)/$(PROJECT)
BINFILE = $(PROJECT)_$(PLATFORM).bin
UPLOAD_DEST = /cygdrive/n/$(BINFILE)

INCLUDE_PATHS = -I. \
				-I./mbed \
				-I./mbed/TARGET_LPC1768 \
				-I.mbed/TARGET_LPC1768/TARGET_NXP \
				-I./mbed/TARGET_LPC1768/TARGET_NXP/TARGET_LPC176X \
				-I./mbed/TARGET_LPC1768/TARGET_NXP/TARGET_LPC176X/TARGET_MBED_LPC1768 \
				-I./mbed/TARGET_LPC1768/TOOLCHAIN_GCC_ARM 
LIBRARY_PATHS = -L./mbed/TARGET_LPC1768/TOOLCHAIN_GCC_ARM 
LIBRARIES = -lmbed 
LINKER_SCRIPT = ./mbed/TARGET_LPC1768/TOOLCHAIN_GCC_ARM/LPC1768.ld

# MODSERIAL options
INCLUDE_PATHS	+= -I./MODSERIAL
LIBRARY_PATHS	+= -L./MODSERIAL
LIBRARIES		+= -lMODSERIAL
MODSERIAL_LIB	= ./MODSERIAL/libMODSERIAL.a

############################################################################### 
AS      = $(GCC_BIN)/arm-none-eabi-as
CC      = $(GCC_BIN)/arm-none-eabi-gcc
CPP     = $(GCC_BIN)/arm-none-eabi-g++
LD      = $(GCC_BIN)/arm-none-eabi-gcc
OBJCOPY = $(GCC_BIN)/arm-none-eabi-objcopy
OBJDUMP = $(GCC_BIN)/arm-none-eabi-objdump
SIZE    = $(GCC_BIN)/arm-none-eabi-size 


CPU = -mcpu=cortex-m3 -mthumb 
CC_FLAGS = $(CPU) -c -g -fno-common -fmessage-length=0 -Wall -Wextra -fno-exceptions -ffunction-sections -fdata-sections -fomit-frame-pointer -MMD -MP
CC_FLAGS += -Wno-unused-parameter -Wno-write-strings
CC_SYMBOLS = -DTOOLCHAIN_GCC_ARM \
			 -DTOOLCHAIN_GCC \
			 -DMBED_BUILD_TIMESTAMP=1448083447.58 \
			 -DARM_MATH_CM3 -DTARGET_CORTEX_M \
			 -DTARGET_LPC176X \
			 -DTARGET_NXP \
			 -DTARGET_MBED_LPC1768 \
			 -DTARGET_LPC1768 \
			 -D__CORTEX_M3 \
			 -DTARGET_M3 \
			 -D__MBED__=1 

LD_FLAGS = $(CPU) -Wl,--gc-sections --specs=nano.specs -u _printf_float -u _scanf_float -Wl,--wrap,main -Wl,-Map=$(PROBJ).map,--cref
LD_SYS_LIBS = -lstdc++ -lsupc++ -lm -lc -lgcc -lnosys

#Colors
Y = "\e[0;33m"
G = "\e[1;32m"
N = "\e[0m"


ifeq ($(DEBUG), 1)
  CC_FLAGS += -DDEBUG -O0
else
  CC_FLAGS += -DNDEBUG -Os
endif

.PHONY: all clean lst size upload
all: modserial $(BINFILE) $(PROBJ).hex size

.PHONY: modserial modserial-clean
modserial:
	@echo -e $(Y)"Making all in MODSERIAL"$(N)
	make -C MODSERIAL all

modserial-clean:
	make -C MODSERIAL clean

clean: modserial-clean
	rm -rf $(BINFILE) $(OBJDIR)

upload: all
	cp $(BINFILE) $(UPLOAD_DEST)

$(OBJDIR):
	mkdir -p $(OBJDIR)

$(CPPOBJECTS) : $(OBJDIR)/%.o : %.cpp | $(OBJDIR)
	@echo -e $(Y)$@$(N)
	$(CPP) $(CC_FLAGS) $(CC_SYMBOLS) -std=gnu++98 -fno-rtti $(INCLUDE_PATHS) -o $@ $<

$(BINFILE): $(PROBJ).elf
	@echo -e $(Y)$@$(N)
	$(OBJCOPY) -O binary $< $@

$(PROBJ).elf: $(MODSERIAL_LIB) $(OBJECTS) $(SYS_OBJECTS)
	@echo -e $(Y)$@$(N)
	$(LD) $(LD_FLAGS) -T$(LINKER_SCRIPT) $(LIBRARY_PATHS) -o $@ $^ $(LIBRARIES) $(LD_SYS_LIBS)

$(PROBJ).hex: $(PROBJ).elf
	@$(OBJCOPY) -O ihex $< $@

$(PROBJ).lst: $(PROBJ).elf
	@$(OBJDUMP) -Sdh $< > $@

lst: $(PROBJ).lst

size: $(PROBJ).elf
	@echo -e $(G)"\nBuild complete!"$(N)
	$(SIZE) $(PROBJ).elf

DEPS = $(OBJECTS:.o=.d) $(SYS_OBJECTS:.o=.d)
-include $(DEPS)
