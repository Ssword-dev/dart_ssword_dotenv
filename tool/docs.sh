#!/bin/bash

# Check if dartdoc is installed
if ! command -v dartdoc &> /dev/null
then
    echo "dartdoc not found. Installing dartdoc..."
    dart pub global activate dartdoc
fi

# Generate documentation in docs/api
dartdoc --output docs/api