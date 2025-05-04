#!/usr/bin/env python3
"""
This script takes in a tree of EPUB files which may be nested as deep as you want,
and outputs them all into one directory named `flat/`
"""
import os
import re
import shutil
import argparse

def compact_tree(input_dir, output_dir):
    all_epubs = []
    for root, dirs, files in os.walk(input_dir):
        for file in files:
            if file.endswith('.epub'):
                all_epubs.append(os.path.join(root, file))

    count = len(all_epubs)
    done = 0
    for epub in all_epubs:
        #print(epub)
        story_id = int(re.search(r'([0-9]+)\.epub$', epub).group(1))
        shutil.copy(epub, os.path.join(output_dir, str(story_id) + '.epub'))
        done += 1

        if (done % 1000) == 0:
            print(f"Done {done}/{count}...")

def main():
    parser = argparse.ArgumentParser(description='Flatten a directory tree of EPUB files into a single directory')
    parser.add_argument('--input', '-i', default='fimfarchive/epub/',
                      help='Input directory containing EPUB files (default: fimfarchive/epub/)')
    parser.add_argument('--output', '-o', default='flat/',
                      help='Output directory for flattened EPUB files (default: flat/)')
    
    args = parser.parse_args()
    
    # Create output directory if it doesn't exist
    os.makedirs(args.output, exist_ok=True)
    
    compact_tree(args.input, args.output)

if __name__ == '__main__':
    main()
