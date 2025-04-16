#!/usr/bin/env bash

schemas="$(cat sql/manifest.txt)"

for s in $schemas; do
  psql --csv -v nspname="'$s'" -f ./scripts/print-schema-definition.sql | ./scripts/csv2src.py &&
    psql --csv -v nspname="'$s'" -f ./scripts/print-function-definition.sql | ./scripts/csv2src.py
done
