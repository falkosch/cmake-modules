#!/usr/bin/env bash

mkdir -p gcov
rm -f gcov/*.gcov

find . -name "*.gcno" \
    -exec sh -c "LC_ALL=en_US LANG=en_US gcov -abcflmp \${1%.gcno}.o > /dev/null" _ {} \;

mv -t gcov *.gcov || true
