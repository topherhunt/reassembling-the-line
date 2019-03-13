# Reassembling the Line

Record video interviews where people share first-hand experience on an important topic. Code each segment of the video by theme. Explore the results using a novel filterable segment playback UI.

Check out the demo to see more: [https://rtl-demo1.herokuapp.com](https://rtl-demo1.herokuapp.com)

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
* `heroku run -a rtl "POOL_SIZE=2 mix ecto.migrate"`
* `heroku run -a rtl "POOL_SIZE=2 iex -S mix"`

More documentation at: https://hexdocs.pm/phoenix/heroku.html

### How to deploy to a new Heroku app

Assumes you're familiar with and set up with Git, Heroku CLI, and Elixir.

* Clone this repository to your local machine
* `heroku create rtl-demo1 \
    --buildpack "https://github.com/HashNuke/heroku-buildpack-elixir.git"`
* `heroku buildpacks:add -a rtl-demo1 \
    https://github.com/gjaldon/heroku-buildpack-phoenix-static.git`
* `heroku addons:create -a rtl-demo1 heroku-postgresql:hobby-dev`
* `git remote add heroku-demo1 https://git.heroku.com/rtl-demo1.git`
* Create an S3 bucket to hold files for this app. The AWS credentials you provide in the next step must have full R/W access, but no other special permissions are needed.
* Copy `config/secrets.exs.sample` to `config/secrets.exs`; fill in real values for your app environment. The AWS credentials you specify must have access to the bucket you specify.
* `heroku config:set -a rtl-demo1 KEY=value KEY2=value2`
* `git push heroku-demo1 master`
* `heroku run -a rtl-demo1 "POOL_SIZE=2 mix ecto.migrate"`
* `heroku run 'mix run priv/repo/insert_coder.exs "Elmer" elmer.fudd@example.com'`

### How to populate videos in a Heroku app

* Make a .tsv list of Youtube videos to import. (Currently we only have a YouTube import script.) See `priv/repo/videos_import_youtube.exs` for details.
* In your dev environment, run the Youtube importer. See `priv/repo/videos_import_youtube.exs` for details.
* Export the videos to a dumpfile, then execute that dump in the Heroku environment. See `mix run priv/repo/videos_dump.exs`.
* Use the scripts in `priv/repo/` to set up a database of videos and export them to the new Heroku environment
* `heroku open`

### Reset database state:

- `heroku pg:reset`
- `heroku run mix ecto.migrate`
- `heroku run mix run priv/repo/seeds.exs`

## Elixir troubleshooting primer

- Haml: it's easy to get the syntax wrong when embedding Elixir logic. Extract complex logic to View helpers where possible, especially anything that might trigger exceptions. See https://github.com/nurugger07/calliope for correct syntax (may need to do a little trial & error). You can also hack the `phoenix_haml` dependency to print out the `eex` string compiled by Calliopee; often this makes it obvious why the eex parser is complaining. (Need to run `mix deps.compile` after changing code in deps.)
