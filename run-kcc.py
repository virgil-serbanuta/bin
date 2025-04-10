#!/usr/bin/env python3

import os.path
import sys
import subprocess

MATCH = 1
C_SEMANTICS = 2

DEBUG = C_SEMANTICS

if DEBUG == MATCH:
    DIST_DIR = '/home/virgil/runtime-verification/rv-match/c-semantics-plugin/src/main/ocaml/dist'
    PROFILE = 'x86_64-linux-gcc-glibc-gnuc'
    OPTIONS = '`_Set_`(`SetItem`(`Link`(.KList)), `.Set`(.KList))'
else:
    DIST_DIR = '/home/virgil/runtime-verification/c-semantics/dist'
    PROFILE = 'x86-gcc-limited-libc'
    OPTIONS = "`_Set_`(`SetItem`(`Link`(.KList)), `_Set_`(`SetItem`(`NoNativeFallback`(.KList)), `.Set`(.KList)))"

KCC_DIR = os.path.join(os.path.join(DIST_DIR, 'profiles'), PROFILE)
KCC_LINK_DIR = os.path.join(KCC_DIR, 'c-cpp-linking-kompiled/c-cpp-linking-kompiled')

def link(input, objs, depth):
    subprocess.run(
        [os.path.join(KCC_LINK_DIR, 'interpreter'),
        os.path.join(KCC_LINK_DIR, 'realdef.cma'),
        input,
        '--output-file',
        '/mnt/data/runtime-verification/tmp/cfg',
        '-c',
        'OPTIONS',
        OPTIONS,
        'text',
        '-c',
        'JSON',
        r'#token("\"{\\\"suppressions\\\": [],\\\"message_length\\\": 80,\\\"format\\\": \\\"Console\\\",\\\"previous_errors\\\": [],\\\"fatal_errors\\\": false,\\\"rv_error\\\": \\\"/home/virgil/runtime-verification/rvp-install/bin/rv-error\\\"}\"", "String")',
        'text',
        '-c',
        'UUID',
        r'#token("\"f8910f48-67ac-11ea-9196-a0e4404931c4\"", "String")',
        'text',
        '-c',
        'OBJS',
        objs,
        'binaryfile',
        '-c',
        'PGM',
        '.K',
        'text',
        '--depth',
        str(depth)]
    )

def compile(depth, output):
    link('.tmp-kcc-NfzE5/syms-lY0NP', '.tmp-kcc-NfzE5/all-objs-lDcqI', depth)
    subprocess.run(
        [os.path.join(DIST_DIR, 'k/bin/k-bin-to-text'),
        '/mnt/data/runtime-verification/tmp/cfg',
        output]
    )

def run(depth, output):
    subprocess.run(
        ['/mnt/data/denso/union.out',
        '--depth', str(depth),
        '--output-file', output,
        '--'
        ]
    )

def kcc(depth, output):
    subprocess.run(
        ['/home/virgil/runtime-verification/rv-match/c-semantics-plugin/src/main/ocaml/dist/kcc',
        '-o', 'isnan.o',
        '/mnt/data/others/coreutils-8.19/lib/isnan.c',
        '-d',
        '-ftranslation-depth=%d' % depth
        ])
    subprocess.run(['/bin/bash', '-c', 'cp kcc_config %s' % output])

def main(argv):
    for i in range(1000000, 1000100, 1):
        print (i)
        destination = '/mnt/data/tmp/kcc_config.' + str(i)
        #compile(i, destination)

        # For run use RV_MATCH_BINARY_FLAGS=1 run-kcc.py
        kcc(i, destination)
        subprocess.run(['indent-parens.py', destination])


if __name__ == "__main__":
    main(sys.argv[1:])
