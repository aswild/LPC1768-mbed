# Makefile to build MODSERIAL library


GCC_BIN  = /opt/gcc-arm-none-eabi/bin
PROJECT  = MODSERIAL
PLATFORM = LPC1768
OBJDIR   = build

CPPSOURCES = $(wildcard *.cpp)
CPPOBJECTS = $(patsubst %.cpp, $(OBJDIR)/%.o, $(CPPSOURCES))

OBJECTS		= $(CPPOBJECTS)

PROBJ	= $(OBJDIR)/$(PROJECT)
LIBFILE = lib$(PROJECT).a

INCLUDE_PATHS = -I. \
				-I../mbed \
				-I../mbed/TARGET_LPC1768 \
				-I../mbed/TARGET_LPC1768/TARGET_NXP \
				-I../mbed/TARGET_LPC1768/TARGET_NXP/TARGET_LPC176X \
				-I../mbed/TARGET_LPC1768/TARGET_NXP/TARGET_LPC176X/TARGET_MBED_LPC1768 \
				-I../mbed/TARGET_LPC1768/TOOLCHAIN_GCC_ARM 

############################################################################### 
AS      = $(GCC_BIN)/arm-none-eabi-as
CC      = $(GCC_BIN)/arm-none-eabi-gcc
CPP     = $(GCC_BIN)/arm-none-eabi-g++
LD      = $(GCC_BIN)/arm-none-eabi-gcc
OBJCOPY = $(GCC_BIN)/arm-none-eabi-objcopy
OBJDUMP = $(GCC_BIN)/arm-none-eabi-objdump
SIZE    = $(GCC_BIN)/arm-none-eabi-size 
AR		= $(GCC_BIN)/arm-none-eabi-ar


CPU = -mcpu=cortex-m3 -mthumb 
CC_FLAGS = $(CPU) -c -g -fno-common -fmessage-length=0 -Wall -Wextra -fno-exceptions -ffunction-sections -fdata-sections -fomit-frame-pointer -MMD -MP
CC_FLAGS += -Wno-unused-parameter
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

#Colors
Y = "\e[0;33m"
G = "\e[1;32m"
N = "\e[0m"


ifeq ($(DEBUG), 1)
  CC_FLAGS += -DDEBUG -O0
else
  CC_FLAGS += -DNDEBUG -Os
endif

.PHONY: all clean

all: $(LIBFILE)

clean:
	rm -rf $(LIBFILE) $(OBJDIR)

$(OBJDIR):
	mkdir -p $(OBJDIR)

$(CPPOBJECTS) : $(OBJDIR)/%.o : %.cpp | $(OBJDIR)
	@echo -e $(Y)"MODSERIAL/"$@$(N)
	$(CPP) $(CC_FLAGS) $(CC_SYMBOLS) -std=gnu++98 -fno-rtti $(INCLUDE_PATHS) -o $@ $<

$(LIBFILE) : $(OBJECTS)
	@echo -e $(Y)"MODSERIAL/"$@$(N)
	$(AR) rcs $@ $^

DEPS = $(OBJECTS:.o=.d) $(SYS_OBJECTS:.o=.d)
-include $(DEPS)
