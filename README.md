# Foam API

Foam API based on RoR. For better results, this application should be developed and deployed under a Unix environment.

## Prerequisites

You will need the following things properly installed on your computer. The recommended way of running this application is via Ruby installed with `rvm`.

- [RVM](http://rvm.io/)
- [Git](https://git-scm.com/)
- [PostgreSQL](https://www.postgresql.org/)

## Installation

- `git clone <repository-url>` this repository
- `cd api`
- `bundle install`
- `bundle exec rake db:setup`

## Setting up the dev environment

- Create a new file called `.env` in the root directory of the application based on `.env.sample`. Fill out the appropriate secrets before running the ruby server daemon.

```
FOAM_AI_DATABASE_USERNAME=
FOAM_AI_DATABASE_PASSWORD=
FOAM_AI_DATABASE_HOST=
FOAM_AI_DATABASE=
...
```

- Install Rails dependencias, via `bundle command`.

```bash
bundle install
```

- Setup `development` and `test` db.

```bash
bundle exec rails db:setup
```

## Setup TextExtractor

Install `text-extractor` lib dependencies:

- pdftotext
- unrtf
- tesseract
- catdoc [Mac](https://apple.stackexchange.com/a/294259)
- xls2csv
- catppt

MacOS:

```bash
brew install poppler
brew install unrtf
brew install tesseract
brew install --build-from-source catdoc.rb
```

Debian/Ubuntu:

```bash
sudo apt install poppler-utils
sudo apt install unrtf
sudo apt install catdoc
sudo apt install tesseract-ocr
...
```

Create symlinks to the `bin` files point to `/usr/bin`. Eg:

MacOS:

```bash
sudo ln -s /opt/homebrew/bin/catdoc /usr/local/bin/catdoc
sudo ln -s /opt/homebrew/bin/catppt /usr/local/bin/catppt
sudo ln -s /opt/homebrew/bin/xls2csv /usr/local/bin/xls2csv
sudo ln -s /opt/homebrew/bin/pdftotext /usr/local/bin/pdftotext
sudo ln -s /opt/homebrew/bin/unrtf /usr/local/bin/unrtf
sudo ln -s /opt/homebrew/bin/tesseract /usr/local/bin/tesseract
```

Debian/Ubuntu:

```bash
sudo ln -s /usr/bin/catdoc /usr/local/bin/catdoc
sudo ln -s /usr/bin/catppt /usr/local/bin/catppt
sudo ln -s /usr/bin/pdftotext /usr/local/bin/pdftotext
sudo ln -s /usr/bin/unrtf /usr/local/bin/unrtf
sudo ln -s /usr/bin/tesseract /usr/local/bin/tesseract
sudo ln -s /usr/bin/xls2csv /usr/local/bin/xls2csv
```

## Running / Development

- `rails s`
- Visit your app at [http://localhost:3000](http://localhost:3000).

### Sidekiq

This app uses `sidekiq` for background jobs. To start the sidekiq daemon, run the following command:

```bash
bundle exec sidekiq
```

## Testing

This application uses `rspec` and `parallel_tests` for unit and integration testing.

ParallelTests uses 1 database per test-process, add the following to your `.env` file with the number of parallel tests to be performed:

```sh
# ParallelTests
TEST_ENV_NUMBER=2
```

Create additional database(s)

```sh
rake parallel:setup
```

Before you commit your changes, make sure you've tested everything with the following commands:

- `rake parallel:spec`

## Lint

This application uses `rubocop` for ruby style checking.

- `rubocop`

## ERD

This application uses `rails-erd` for ruby style checking.

- `bundle exec erd`

# Unix Libs

This application uses GNU's `sed` and `psql` binaries to sync DID libs. Install `gnu-sed` and `psql` client via homebrew or other package manager.

For mac os x, follow this link:

- [SED](https://formulae.brew.sh/formula/gnu-sed)

Once the binaries are installed, get their path using `which` cmd. Configure ENV vars with its output.

```bash
which sed
# => ENV['SED_BIN']=/bin/sed
which psql
# => ENV['PSQL_BIN']=/usr/local/bin/psql
```

## Stage

### .env

Add the following:

```sh
# Docker
WORKER_PROCESSES=1
LISTEN_ON=0.0.0.0:9010
# Database credentials
COMPARTCARGA_HOST=postgres
COMPARTCARGA_USERNAME=gitlab
```

### Deploy

```sh
git pull
docker-compose down
sudo chown -R $USER:$USER tmp/
```

Password prompt.

```sh
docker-compose build
docker-compose up -d
docker-compose run internet-web rake db:migrate
```

#### Stage Deploy

**Stage:**

- `bundle exec cap stage deploy`
- API is available at `https://chato.api-stage.koonolmexico.com`

# Docs

Use `yard` to generate docs.

1. Install yard

```bash
gem install yard
```

2. Generate Doc

```bash
yardoc 'app/controllers/**/*.rb'
```
