#!/usr/bin/env bash

schemas="$(cat sql/manifest.txt)"

for s in $schemas; do
  psql --csv -v nspname="'$s'" -f ./sql/scripts/print-schema-definition.sql | ./sql/scripts/csv2src.py &&
    psql --csv -v nspname="'$s'" -f ./sql/scripts/print-function-definition.sql | ./sql/scripts/csv2src.py
done
