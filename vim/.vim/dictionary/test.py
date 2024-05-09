#!/usr/bin/python3
import sys

while line := sys.stdin.readline():
    line = line.replace('\t', ' ').split(' ')
    if len(line) < 2:
        continue
    if line[1] != 'keyword' and line[1] != 'Keyword':
        continue
    print(' '.join(line[3:]))
