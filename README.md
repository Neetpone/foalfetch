# FoalFetch
A replacement for FiMFetch.

## App Setup
Standard stuff. Get a Ruby environment however you'd like for the app, I like chruby and ruby-install. Do your standard `bundle install` and `rake db:setup` or `rake db:schema:load`.
You will also likely have to do `rails credentials:edit` and set a secret key for the app.

### Running the App
`rails s` should do it. Be sure to set `RAILS_ENV=production` in your environment. After first install, and after you upgrade the app, make sure to do `rake db:migrate` and `rake assets:precompile`.
I recommend running the app behind NGINX using a standard reverse-proxy configuration, but have NGINX serve static files from `/public`.

## Data Importing
The FoalFetch data is sourced from FimFArchive. I have written a set of Python scripts to help get this data onto FoalFetch.

### Setting Up the Scripts
Look at `tools/requirements.txt` and install the requirements however you prefer. If you're just using systemwide Pip or a normal VirtualEnv, `pip install -r tools/requirements.txt` should do it.

### Getting the Data
Download the latest torrent from [here](https://www.fimfiction.net/user/116950/Fimfarchive).

Put the zip file in a dedicated "work" directory for this project - you'll need some room to breath.
Extract the zip file; I'll assume you extract it to a subdirectory called `fimfarchive/`.

### Processing the Data
#### Flattening the Tree
First, you need to flatten the tree. This will take the EPUB folder from FimFArchive, and compact it down into
a single directory of EPUB files. This makes dealing with the data easier for the other scripts.

Run `tools/compact_tree.py -i <epub dir> -o <flat output dir>`. For example, `tools/compact_tree.py -i fimfarchive/epub -o flat/`. Wait a bit for it to run. This will double the disk space usage. Sorry.

#### Generating the CSV
Now we need to parse the index JSON and story EPUBs into CSV files that can be imported into SQL.

Run `tools/parse_index.py -i <index file> -o <CSV output dir> -e <flat epub dir>`. For example, `tools/parse_index.py -i fimfarchive/index.json -o csv/ -e flat/`.

Wait awhile. This can take anywhere from 15 minutes to an hour depending on how fast your CPU and hard drive are. Progress will be printed as it runs.

**This is a potentially-lossy process because it converts the HTML in the EPUB files to Markdown, but I haven't experienced any issues with this.**

#### Cleaning Up the CSV
For some reason, `authors.csv` always ends up with duplicate entries, which will anger PostgreSQL when we try to import the data. Run `tools/remove_duplicate_ids.py csv/authors.csv csv/authors_dedup.csv` to fix this.

### Importing the Data
This is the least fun part. I hope to have a better system in place soon. These steps assume you have already set up the app's DB according to the above instructions.

There's an order you need to do this in; the order is the same as listed below. You will need to substitute the username and DB name for whatever you are using; the examples provided are the defaults.
Stories will take a minute or two, and chapters will take forever, expect around 15 minutes.
One of the steps (stories or chapters, I forget) may get angry about a null value in the word count column. Alter that column to make the default 0. It would be faster for me to write a migration to fix it than type this, but I'm lazy.

#### Tags
```bash
psql -h localhost -U foalfetch foalfetch_production -c 'COPY tags (id, name, old_id, type) FROM stdin WITH (FORMAT csv, ON_ERROR ignore)' < tags.csv
```

#### Authors
```bash
psql -h localhost -U foalfetch foalfetch_production -c 'COPY authors (id, name, num_blog_posts, num_followers, avatar, bio_html, date_joined) FROM stdin WITH (FORMAT csv, ON_ERROR ignore)' < authors_dedup.csv
```

#### Stories
```bash
psql -h localhost -U foalfetch foalfetch_production -c 'COPY stories (id, author_id, color, completion_status, content_rating, cover_image, date_published, date_updated, date_modified, description_html, num_comments, num_views, prequel, rating, short_description, title, total_num_views) FROM stdin WITH (FORMAT csv, ON_ERROR ignore)' < stories.csv
```

#### Taggings
```bash
psql -h localhost -U foalfetch foalfetch_production -c 'COPY story_taggings (story_id, tag_id) FROM stdin WITH (FORMAT csv, ON_ERROR ignore)' < taggings.csv
```

#### Chapters
```bash
psql -h localhost -U foalfetch foalfetch_production -c 'COPY chapters (id, story_id, number, date_published, date_modified, num_views, title, body) FROM stdin WITH (FORMAT csv, ON_ERROR ignore)' < chapters.csv
```

### Finishing Up
Open up a Rails console, and do `Story.__elasticsearch__.import(force: true)`. This indexes all the stories into ElasticSearch; it may take a while.
After that, run `RecountWordsJob.perform_now`. This fills in all the word counts for all the stories and chapters. This will also take a while.