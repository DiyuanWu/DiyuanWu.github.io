#!/bin/bash

# Remove HTML files in root directory
rm -f *.html

# Remove HTML files in src/html directory
rm -f ./src/html/*.html



# Run the markdown to HTML conversion script
python ./src/md2html.py

# Check if the conversion was successful
if [ $? -eq 0 ]; then
    # Copy generated HTML files and styles.css to current directory
    cp -r ./src/html/* .
    echo "Deployment successful!"
else
    echo "Error: Markdown conversion failed. Deployment aborted."
    exit 1
fi
