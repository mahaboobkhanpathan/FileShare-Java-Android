#!/usr/bin/env bash
set -e
echo "============================================"
echo "  Building FileShare Application"
echo "============================================"

mkdir -p bin shared downloads database
javac -encoding UTF-8 -cp "lib/*" -d bin src/common/*.java src/database/*.java src/server/*.java src/client/*.java src/test/*.java
echo "Build completed successfully in bin/"
