#!/usr/bin/env python3
# There is like a 50% chance this piece of garbage will dead lock, so if you don't get the "Submitted n tasks..." message
# after a couple minutes and there's no CPU usage, restart it.
import os
import re
import csv
import sys
import json
import logging
import argparse
import concurrent.futures
import multiprocessing

from datetime import datetime
from collections import namedtuple
from parse_epub import parse_book

# How many ziggers (workers) to start
ZIGGERS_COUNT = 22

class DefaultableDigger:
    def __init__(self, parent, defaults={}):
        self._dict = parent
        self._defaults = _defaults

    def dig(self, *args):
        current = self._dict
        for arg in args:
            if not current:
                break

            current = current.get(arg)

        return current

    def dig2(self, path, default):
        result = self.dig(path)
        if not result:
            return default

        return result

    def __getitem__(self, key):
        """
        Get an item from the dict, returning an appropriately-typed default if the key isn't in the dict.
        """
        return self._dict.get(key) or self._defaults.get(key)

    def __setitem__(self, key, value):
        self._dict[key] = value

ChapterInfo = namedtuple('ChapterInfo', ('id', 'story_id', 'ordinal', 'date_published', 'date_modified', 'num_views', 'title', 'body'))
StoryInfo = namedtuple('StoryInfo', (
    'id', 'author_id', 'color', 'completion_status', 'content_rating', 'cover_image', 'date_published', 'date_updated', 'date_modified',
    'description_html', 'num_comments', 'num_views', 'prequel', 'rating', 'short_description', 'title', 'total_num_views'
))
TagInfo = namedtuple('TagInfo', (
    'id', 'name', 'old_id', 'type'
))
AuthorInfo = namedtuple('AuthorInfo', (
    'id', 'name', 'num_blog_posts', 'num_followers', 'avatar', 'bio_html', 'date_joined'
))

# _dig(my_dict, 'foo', 'bar', 'baz') is equivalent to my_dict['foo']['bar']['baz'] except if one of the keys
# doesn't exist, it returns None.
def _dig(dic, *args):
    top_level = dic
    for arg in args:
        if not top_level:
            break

        top_level = top_level.get(arg)

    return top_level

# _ior(val, default) is equivalent to `val if val else default`
def _ior(val, default):
    if not val:
        return default

    return val

def _color(val):
    if val:
        return int(val, 16)

    return None

def _date(val):
    if not val:
        return None
    m = re.match(r'^[0-9]+$', str(val))
    if m:
        return datetime.fromtimestamp(int(m.group(0))).isoformat()

    return None


def get_content_rating(story):
    # older version of the data
    if 'content_rating_text' in story:
        return story.get('content_rating_text', '').lower()

    return story.get('content_rating')

def get_date_field(story, field):
    result = story.get(field)

    if isinstance(result, float) or isinstance(result, int):
        return datetime.fromtimestamp(result).isoformat()

    return result or '1970-01-01T00:00:00+00:00'

def get_completion_status(story):
    if 'completion_status' in story:
        return story.get('completion_status')

    return story.get('status', '').lower()

def get_first_field(story, *args):
    for field in args:
        if field in story:
            return story.get(field)

def dump_rows(rows, path):
    with open(path, 'w') as fp:
        writer = csv.writer(fp)
        for row in rows:
            writer.writerow(row)

def load_index_file(path='index.json'):
    with open(path, 'r') as fp:
        return json.load(fp)

def collect_tags(story):
    if 'tags' in story:
        return {
            TagInfo(tag['id'], tag['name'], tag['old_id'], tag['type'])
                for tag in story['tags']
        }
    elif 'categories' in story:
        # TODO
        pass

def collect_taggings(story):
    if 'tags' in story:
        return [(story['id'], tag['id']) for tag in story['tags']]

    return []

def dump_shared_metadata(index, outdir='.'):
    all_tags = set()
    all_authors = set()
    all_taggings = set()

    def _get_avatar(author):
        avatars = author.get('avatar')

        if avatars:
            return avatars.get('512')

        return None

    for story_id, story in index.items():
        author = story['author']

        all_tags.update(collect_tags(story))
        all_taggings.update(collect_taggings(story))
        all_authors.add(
            AuthorInfo(
                author['id'], author['name'], author.get('num_blog_posts', 0) or 0, author.get('num_followers', 0) or 0,
                _dig(author, 'avatar', '512'), author.get('bio_html'), get_date_field(author, 'date_joined')
            )
        )

    dump_rows(all_tags, os.path.join(outdir, 'tags.csv'))
    dump_rows(all_taggings, os.path.join(outdir, 'taggings.csv'))
    dump_rows(all_authors, os.path.join(outdir, 'authors.csv'))

def _dump_story(info, do_chapters, epub_dir):
    story_id, story = info
    story_info = StoryInfo(
        id=story['id'], author_id=story['author']['id'],
        color=_color(_dig(story, 'color', 'hex')),
        completion_status=get_completion_status(story), content_rating=get_content_rating(story), cover_image=_dig(story, 'cover_image', 'full'),
        date_published=get_date_field(story, 'date_published'), date_updated=get_date_field(story, 'date_updated'), date_modified=get_date_field(story, 'date_modified'),
        description_html=get_first_field(story, 'description_html', 'description'),
        num_comments=(story.get('num_comments', 0) or 0), num_views=(story.get('num_views', 0) or 0),
        prequel=story.get('prequel'), rating=story.get('rating', 0), 
        short_description=story.get('short_description'), title=(story.get('title') or '##NULL##'), total_num_views=(get_first_field(story, 'total_num_views', 'total_views') or 0)
    )

    if not do_chapters:
        return story_info, []

    chapters = []

    chapters_infos = {
        info.ordinal: info.content
            for info in parse_book(os.path.join(epub_dir, story_id + '.epub'))
    }

    for chapter in story.get('chapters', []):
        chapters.append(
            ChapterInfo(
                chapter['id'], story_id, chapter.get('chapter_number', 1), get_date_field(chapter, 'date_published'), _date(chapter.get('date_modified')),
                chapter.get('num_views', 0) or 0, (chapter.get('title') or '##NULL##'), chapters_infos.get(chapter.get('chapter_number', 1))
            )
        )

    return story_info, chapters

def dump_story(info, do_chapters, epub_dir):
    try:
        return _dump_story(info, do_chapters, epub_dir)
    except Exception:
        logging.exception(f"Failed to dump story {info[0]}")

def dump_stories(index, outdir='.', do_chapters=False, num_workers=None, epub_dir='flat'):
    if num_workers is None:
        num_workers = multiprocessing.cpu_count()
        
    stories_writer = csv.writer(open(os.path.join(outdir, 'stories.csv'), 'w'))

    if do_chapters:
        chapters_writer = csv.writer(open(os.path.join(outdir, 'chapters.csv'), 'w'))

    done_count = 0
    error_count = 0
    chapters_count = 0

    # Not using a context manager because for some reason it swallows all exceptions in the loop
    # until the executor shuts down.
    exe = concurrent.futures.ProcessPoolExecutor(max_workers=num_workers)
    logging.info(f"Submitting {len(index)} tasks to {num_workers} workers")
    futures = [exe.submit(dump_story, item, do_chapters, epub_dir) for item in index.items()]
    logging.info(f"Submitted {len(futures)} tasks to {num_workers} workers")

    for future in concurrent.futures.as_completed(futures):
        result = future.result()
        if not result:
            error_count += 1
            continue

        stories_writer.writerow(result[0])

        if do_chapters:
            for chapter in result[1]:
                chapters_writer.writerow(chapter)
                chapters_count += 1
        
        done_count += 1
        if (done_count % 1000) == 0:
            logging.info(f"Workers have processed {done_count}/{len(futures)} stories. {error_count} failed. So far I have {chapters_count} chapters.")

def main(argv):
    parser = argparse.ArgumentParser(description='Parse Fimfiction index and generate CSV files')
    parser.add_argument('--index', '-i', default='index.json', help='Path to index.json file')
    parser.add_argument('--output', '-o', default='.', help='Output directory for CSV files')
    parser.add_argument('--epub-dir', '-e', default='flat', help='Directory containing EPUB files')
    parser.add_argument('--no-chapters', action='store_true', help='Skip chapter parsing')
    parser.add_argument('--workers', '-w', type=int, default=multiprocessing.cpu_count(), 
                       help='Number of worker processes (default: number of CPUs)')
    
    args = parser.parse_args(argv[1:])
    
    logging.basicConfig(level=logging.INFO, format='[%(asctime)s] %(levelname)s: %(message)s', datefmt='%m/%d/%Y %I:%M:%S %p')
    # index is keyed by the chapter ID
    logging.info('Loading index file...')
    index = load_index_file(args.index)
    logging.info('Dumping authors and tags...')
    dump_shared_metadata(index, args.output)
    logging.info('Dumping stories, this will take a while...')
    dump_stories(index, args.output, not args.no_chapters, args.workers, args.epub_dir)

    return 0

if __name__ == '__main__':
    sys.exit(
        main(sys.argv)
    )
