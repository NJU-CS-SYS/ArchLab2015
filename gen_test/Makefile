ifndef CROSS_COMPILE
#CROSS_COMPILE = mips-linux-gnu-
CROSS_COMPILE = /home/zyy/mips_tool_chain/buildroot-2015.08.1/output/host/usr/bin/mips-buildroot-linux-gnu-
endif
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
	
export	CROSS_COMPILE

.PHONY: asm
# ********************
# Rules of Compilation
# ********************

all:$(OBJECTS)
	$(LD) $(LDFLAGS) -T ram-board.ld $(OBJECTS) -o boot
	$(OBJCOPY) -O binary boot boot.bin
	$(OBJDUMP) -D boot  > code.txt
	python ./bin2text.py boot.bin ram.txt
run:
	qemu-system-mipsel -kernel boot -serial stdio
debug:
	qemu-system-mipsel -kernel boot -serial stdio  -S -gdb tcp::1234
clean:
	-rm boot* $(OBJECTS) $(OBJECTS:.o=.d) code.txt 
concat:
	cat ./.qiangpozheng/head ./.qiangpozheng/sout ./.qiangpozheng/tail > start.S
regen:
	rm ./.qiangpozheng/sout
gen:
	python3 asmgen2.py

asm: $(CSRC)
	$(CC) $(SCFLAGS) $(CSRC) -o ../tools/q.S
