CROSS_COMPILE = mips-linux-gnu-
AS = $(CROSS_COMPILE)as
CC = $(CROSS_COMPILE)gcc
LD = $(CROSS_COMPILE)ld
OBJCOPY = $(CROSS_COMPILE)objcopy
OBJDUMP = $(CROSS_COMPILE)objdump


CFLAGS = -MD -fno-pic -static -fno-strict-aliasing -fno-builtin  -fno-stack-protector -mno-check-zero-division -fno-delayed-branch -Wall -Werror -EL -march=mips32r2 -mno-llsc -mno-imadd -mno-mad -I../include -O2
SCFLAGS = -MD -fno-pic -static -fno-strict-aliasing -fno-builtin  -fno-stack-protector -mno-check-zero-division -fno-delayed-branch -Wall -Werror -EL -march=mips32r2 -mno-llsc -mno-imadd -mno-mad -I../include -O2 -S
CFLAGS += -g
ASFLAGS = -MD -EL -mno-check-zero-division -mips32r2 -O2
LDFLAGS = -EL


CSRC = $(shell find . -name "*.c") 
SSRC = $(shell find . -name "*.S") 
OBJECTS = $(SSRC:.S=.o) $(CSRC:.c=.o) 
ASMS = $(CSRC:.c=.S)
	
export CROSS_COMPILE

.PHONY: asm

# ********************
# Rules of Compilation
# ********************

all:$(OBJECTS)
	$(LD) $(LDFLAGS) -T ram-board.ld $(OBJECTS) -o boot
	$(OBJCOPY) -O binary boot boot.bin
	$(OBJDUMP) -D boot  > code.txt
	python ./bin2text.py boot.bin ram.txt

qemu:
	$(LD) $(LDFLAGS) -T qemu.ld $(OBJECTS) -o qemu.bin
	$(OBJDUMP) -D qemu.bin > qemu.txt
	qemu-mipsel-static -g 1234 qemu.bin &
	gdb-multiarch qemu.bin -ex "set arch mips" -ex "set endian little" -ex "target remote :1234"
clean:
	-rm -f boot *.bin *.d *.o *.txt 2> /dev/null

TOOL_DIR = ../tools

asm: $(CSRC)
	@$(CC) $(SCFLAGS) $(CSRC) -o $(TOOL_DIR)/tmp_disassembly.S
	cd $(TOOL_DIR) && python gen_spimasm.py
	cd $(TOOL_DIR) && rm tmp_disassembly.*

