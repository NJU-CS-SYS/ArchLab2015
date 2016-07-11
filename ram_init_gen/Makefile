# CROSS_COMPILE = mips-linux-gnu-
CROSS_COMPILE = mipsel-linux-
AS = $(CROSS_COMPILE)as
CC = $(CROSS_COMPILE)gcc
LD = $(CROSS_COMPILE)ld
OBJCOPY = $(CROSS_COMPILE)objcopy
OBJDUMP = $(CROSS_COMPILE)objdump


CFLAGS = -MD -fno-pic -static -fno-strict-aliasing -fno-builtin
CFLAGS += -fno-stack-protector -mno-check-zero-division -fno-delayed-branch
CFLAGS += -Wall -Werror -EL -march=mips32 -mno-llsc
# CFLAGS += -mno-imadd
CFLAGS += -mno-mad -std=gnu99
CFLAGS += -I./inc -O2 -Wno-unused-function
CFLAGS += -mno-abicalls -g
SCFLAGS = -MD -fno-pic -static -fno-strict-aliasing -fno-builtin
SCFLAGS += -fno-stack-protector -mno-check-zero-division -fno-delayed-branch
SCFLAGS += -Wall -Werror -EL -march=mips32 -mno-llsc -mno-imadd -mno-mad
SCFLAGS += -I../include -O2 -S -Wno-unused-function
ASFLAGS = -MD -EL -mno-check-zero-division -mips32 -O0 -mno-abicalls
ASFLAGS += -fno-pic -fno-delayed-branch
LDFLAGS = -EL


CSRC = $(shell find . -name "*.c")
SSRC = $(shell find . -name "*.S")
OBJECTS = $(SSRC:.S=.o) $(CSRC:.c=.o)
DOT_D = $(SSRC:.S=.d) $(CSRC:.c=.d)
ASMS = $(CSRC:.c=.S)

export CROSS_COMPILE

.PHONY: asm

# ********************
# Rules of Compilation
# ********************

all:$(OBJECTS)
	$(LD) $(LDFLAGS) -T ram-board.ld $(OBJECTS) -o boot
	$(OBJCOPY) -O binary boot boot.bin
	$(OBJDUMP) -d boot  > code.txt
	python python/bin2text.py boot.bin ram.txt
	python python/load_coe_gen.py

qemu:
	$(LD) $(LDFLAGS) -T qemu.ld $(OBJECTS) -o qemu.bin
	$(OBJDUMP) -d qemu.bin > qemu.txt
	qemu-mipsel-static -g 1234 qemu.bin &
	gdb-multiarch qemu.bin -ex "set arch mips" -ex "set endian little" \
		-ex "target remote :1234" -ex "disp /i \$$pc"
clean:
	-rm -f boot *.bin $(DOT_D) $(OBJECTS) main.c *.txt 2> /dev/null

TOOL_DIR = ../tools

asm: $(CSRC)
	@$(CC) $(SCFLAGS) $(CSRC) -o $(TOOL_DIR)/tmp_asm.S
	cd $(TOOL_DIR) && python gen_spimasm.py tmp_asm.S spim.S
	cd $(TOOL_DIR) && rm -f tmp_asm.* 2> /dev/null
	rm -f tmp_asm.* 2> /dev/null
	cd $(TOOL_DIR) && python cmp.py -h

