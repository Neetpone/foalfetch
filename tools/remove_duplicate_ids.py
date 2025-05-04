"""
Remove rows with duplicate IDs in the first column of a CSV file.
"""
import csv
import argparse

parser = argparse.ArgumentParser(description='Remove rows with duplicate IDs in the first column of a CSV file.')
parser.add_argument('input_csv', help='Path to the input CSV file')
parser.add_argument('output_csv', help='Path to the output CSV file (deduplicated)')
args = parser.parse_args()

seen_ids = set()
rows = []

with open(args.input_csv, newline='', encoding='utf-8') as infile:
    reader = csv.reader(infile)
    for row in reader:
        if not row:
            continue  # skip empty rows
        id_ = row[0]
        if id_ not in seen_ids:
            seen_ids.add(id_)
            rows.append(row)

with open(args.output_csv, 'w', newline='', encoding='utf-8') as outfile:
    writer = csv.writer(outfile)
    writer.writerows(rows)
