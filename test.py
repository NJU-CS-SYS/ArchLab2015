#!/usr/bin/env python3

import os
import os.path
import sys
import time
import shutil
import argparse

parser = argparse.ArgumentParser(description='Top level test inferface. Finish the work under the root directory')
parser.add_argument('cfile', metavar='c_file',
        help='C file to be compiled. Find them under testcase/')
parser.add_argument('tool', metavar='debug_tool', nargs='?',
        choices=['none', 'qemu', 'spim'], default='none',
        help='Use gdb with qemu or gdb to check the execution flow')
args = parser.parse_args();  # parse sys.argv

def make(path, command):
    cwd = os.getcwd()
    dst = os.path.join(cwd, path)
    if os.path.exists(dst):
        os.chdir(dst)
    else:
        sys.exit('{0} does not have sub dir {1}'.format(cwd), (path))
    os.system('make {0}'.format(command))
    os.chdir(cwd)

nr_argv = len(sys.argv)

build_dir  = 'ram_init_gen'
# cfile_dir  = 'testcase'
cfile_dir  = ''
cfile_name = 'main.c'  # Use the same name in build dir to avoid multi main

# Build c file
src = os.path.join(os.getcwd(), cfile_dir, args.cfile)
if os.path.isfile(src):
    print('Compile {0}'.format(src))
    dst = os.path.join(os.getcwd(), build_dir, cfile_name)
    shutil.copy(src, dst)
    make('ram_init_gen', '')
else:
    sys.exit('{0} does not exists'.format(src))

if args.tool == 'spim':
    make('ram_init_gen', 'asm')
    print('Get into ./tools/ to run your spim')
elif args.tool == 'qemu':
    print('Warning: qemu-mipsel will run in background forever...')
    time.sleep(3)
    make(build_dir, 'qemu')
