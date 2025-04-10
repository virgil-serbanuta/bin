#!/usr/bin/env python3

import sys
from pathlib import Path


def count_lines(name: Path) -> int:
    count = 0
    with name.open() as f:
        for _ in f:
            count += 1
    return count


def output_lines(name: Path, digit_count: int) -> None:
    count = 0
    with name.open() as f:
        for line in f:
            count += 1
            print(f'{{:{digit_count}d}}'.format(count), line[:-1])


def main(argv):
    path = Path(argv[0])
    count = count_lines(path)
    digit_count = 1
    limit = 10
    while limit <= count:
        digit_count += 1
        limit *= 10
    output_lines(path, digit_count)


if __name__ == '__main__':
    # print sys.argv
    main(sys.argv[1:])
