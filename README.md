# EducateYour

## Setting up the dev environment

  * Ensure Erlang, Kiex, Elixir (version in `mix.exs`), and Node are installed
  * `mix deps.get`
  * `npm install`
  * `mix ecto.create`
  * `mix ecto.migrate`
  * `MIX_ENV=test mix ecto.reset_test`
  * `mix run priv/repo/insert_seeds.exs`

## Running the app

  * `mix test` (be sure to start `phantomjs --wd` in another tab first)
  * `mix phoenix.server`
  * `mix run priv/repo/autologins.exs` - list all autologin URLs

## Importing videos

I've written scripts to help with batch importing videos from YouTube. Here's how to use them:

  * Prepare a spreadsheet of YouTube video URLs to import. Each row should have two columns: the human-readable title, and the YouTube URL to download from. Save it as `import_youtube_videos.tsv`.
  * `mix run priv/repo/import_youtube_videos.exs` - This script downloads each video from YouTube, uploads the recording and thumbnail to S3, and inserts the record into the local database. See the source code comments for requirements and details.
  * `mix run priv/repo/export_videos_to_dump.exs` - This script exports the local database of Videos to an executable dump which you can run elsewhere to create those same Video records in another environment.

## Test

  * Run `phantomjs --wd` before running `mix test` (integration tests require this service to be running)

## Heroku

* `git push heroku-production master`
* `heroku run -a educate-your "POOL_SIZE=2 mix ecto.migrate"`
* `heroku run -a educate-your "POOL_SIZE=2 iex -S mix"`

More documentation at: https://hexdocs.pm/phoenix/heroku.html

### Deploying to a new Heroku app

Assumes you're familiar with and set up with Git, Heroku CLI, and Elixir.

* Clone this repository to your local machine
* `heroku create educate-your-demo1 \
    --buildpack "https://github.com/HashNuke/heroku-buildpack-elixir.git"`
* `heroku buildpacks:add -a educate-your-demo1 \
    https://github.com/gjaldon/heroku-buildpack-phoenix-static.git`
* `heroku addons:create -a educate-your-demo1 heroku-postgresql:hobby-dev`
* `git remote add heroku-demo1 https://git.heroku.com/educate-your-demo1.git`
* Copy `config/secrets.exs.sample` to `config/secrets.exs`; fill in real values for the production
* `heroku config:set -a educate-your-demo1 KEY=value KEY2=value2`
* `git push heroku-demo1 master`
* `heroku run -a educate-your-demo1 "POOL_SIZE=2 mix ecto.migrate"`
* `heroku open`

### Reset database state:

- `heroku pg:reset`
- `heroku run mix ecto.migrate`
- `heroku run mix run priv/repo/seeds.exs`
