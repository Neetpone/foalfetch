"""
Reads in an EPUB file and converts all the HTML to Markdown.
"""
import re
import sys
import logging

from ebooklib import epub
from bs4 import BeautifulSoup
from collections import namedtuple
from markdownify import markdownify as md


ChapterInfo = namedtuple('ChapterInfo', ('ordinal', 'content'))

def _parse_chapter_ordinal(s):
    try:
        return False, int(re.match(
            r'Chapter([0-9]+)\.html',
            s
        ).group(1))
    except Exception:
        return True, int(re.match(
            r'Chapter([0-9]+)_split_.+\.html',
            s
        ).group(1))

def parse_book(path):
    book = epub.read_epub(path)
    chapters = []
    accum = ''
    current = -1

    if not book.items:
        logging.warn(f"{path}: Book has no chapters?")
        return chapters

    for item in book.items:
        if isinstance(item, epub.EpubHtml):
            #soup = BeautifulSoup(item.get_body_content(), 'lxml')
            is_split, ordinal = _parse_chapter_ordinal(item.get_name())
            #title = soup.find('h1', class_='calibre1').text

            # Try the different content containers I've seen.
            # content = soup.find('div', id='content')

            # if not content:
            #     content = soup.find('body')
            #     if not content:
            #         content = soup
            #     else:
            #         content.name = 'div'

            # content = str(content)

            content = md(item.get_body_content())

            if ordinal != current and accum:
                chapters.append(
                    ChapterInfo(current, accum)
                )
                #logging.info(f"{path}: Finished processing split chapter {current}")
                # print(f"Finished processing split chapter {current}")
                current = ordinal
                accum = ''
            elif is_split:
                accum += "\n\n" + content
                current = ordinal
            else:
                chapters.append(
                    ChapterInfo(ordinal, content)
                )
            
    return chapters

def main(argv):
    if len(argv) != 2:
        print(f"usage: {argv[0]} <path to book>")
        return 1

    print(
        parse_book(argv[1])
    )
    return 0

if __name__ == '__main__':
    sys.exit(
        main(sys.argv)
    )
