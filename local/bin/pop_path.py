#!/usr/bin/python3

import sys

if sys.argv:
    tokens = sys.argv[1].rstrip('/').split('/')
    print('/'.join(tokens[ : -1]))

