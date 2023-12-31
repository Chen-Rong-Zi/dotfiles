#!/usr/bin/python3
from sys import stdin, argv
from time import sleep


def printer(interval):
        for word in stdin:
            for char in word:
                sleep(interval)
                print(char, end='', flush=True)

def main():
    interval = 0.01 if len(argv) == 1 else float(argv[1])
    try:
        printer(interval)
    except KeyboardInterrupt:
        print('\nprinter exit')

if __name__ == "__main__":
    main()
