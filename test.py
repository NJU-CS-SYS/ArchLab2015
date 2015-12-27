#!/usr/bin/env python3

import os
import os.path
import sys
import time
import shutil

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
cfile_dir  = 'testcase'
cfile_name = 'main.c'  # Use the same name in build dir to avoid multi main

if nr_argv >= 2:
    # Build c file
    src = os.path.join(os.getcwd(), cfile_dir, sys.argv[1])
    if os.path.isfile(src):
        print('Compile {0}'.format(src))
        dst = os.path.join(os.getcwd(), build_dir, cfile_name)
        shutil.copy(src, dst)
        make('ram_init_gen', '')
    else:
        sys.exit('{0} does not exists'.format(src))

    if nr_argv >= 3:
        if sys.argv[2] == 'spim':
            make('ram_init_gen', 'asm')
            print('Get into {0}/tools/ to run your spim')
        elif sys.argv[2] == 'qemu':
            print('Warning: qemu-mipsel will run in background forever...')
            time.sleep(3)
            make(build_dir, 'qemu')
        else:
            print('Unkown option')
else:
    print('Need argument(s): c-file [bonus option]')

