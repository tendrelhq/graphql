#!/usr/bin/env python3

import csv
import sys

_ = csv.field_size_limit(sys.maxsize)

functions = [dict(r) for r in csv.DictReader(sys.stdin)]

for f in functions:
    name = f.get("name")
    src = f.get("src")
    if name and src:
        with open(f"sql/src/{name}.sql", "w") as out:
            _ = out.write(src)
    else:
        print("no good:", f)
