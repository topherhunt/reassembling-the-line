# Reassembling the Line

Record video interviews where people share first-hand experience on an important topic. Code each segment of the video by theme. Explore the results using a novel filterable segment playback UI. Built by Whitney Hunter-Thomson and [Topher Hunt](topherhunt.com).

Check out the demo to see more: [https://rtl-demo1.herokuapp.com](https://rtl-demo1.herokuapp.com)

If you're using this project, **please let us know** so we can learn what works well and how we can improve it! Our goal is to spread this concept as quickly as possible, and we can only do that with your feedback and input.


## Setting up the dev environment

  * Ensure Erlang, Kiex, Elixir (version in `mix.exs`), and Node are installed
  * `mix deps.get`
  * `npm install`
  * `mix ecto.create`
  * `mix ecto.migrate`
  * `MIX_ENV=test mix ecto.reset_test`
  * `mix run priv/repo/insert_seeds.exs`


## Running the app

  * `mix test` (be sure to start `chromedriver` in another tab first)
  * `mix phoenix.server`
  * `mix run priv/repo/autologins.exs` - list all autologin URLs


## Importing videos

I've written scripts to help with batch importing videos from YouTube. Here's how to use them:

  * Prepare a spreadsheet of YouTube video URLs to import. Each row should have two columns: the human-readable title, and the YouTube URL to download from. Save it as `import_youtube_videos.tsv`.
  * `mix run priv/repo/import_youtube_videos.exs` - This script downloads each video from YouTube, uploads the recording and thumbnail to S3, and inserts the record into the local database. See the source code comments for requirements and details.
  * `mix run priv/repo/export_videos_to_dump.exs` - This script exports the local database of Videos to an executable dump which you can run elsewhere to create those same Video records in another environment.


## Test

  * A current version of ChromeDriver must be running in order for integration tests to pass.


## Data privacy

For more info on the GDPR, see: https://www.gdprsummary.com/gdpr-summary/


## Heroku & deployment

* `git push heroku-production master`
* `heroku run -a rtl "POOL_SIZE=2 mix ecto.migrate"`
* `heroku run -a rtl "POOL_SIZE=2 iex -S mix"`

More documentation at: https://hexdocs.pm/phoenix/heroku.html


### How to deploy to a new Heroku app

Assumes you're familiar with and set up with Git, Heroku CLI, Elixir, and Amazon S3. See also the official guide: https://hexdocs.pm/phoenix/heroku.html

  * Clone this repository to your local machine
  * `heroku create rtl-demo1 --buildpack "https://github.com/HashNuke/heroku-buildpack-elixir.git"`
  * `heroku buildpacks:add -a rtl-demo1 https://github.com/gjaldon/heroku-buildpack-phoenix-static.git`
  * `heroku addons:create -a rtl-demo1 heroku-postgresql:hobby-dev`
  * `heroku addons:create -a rtl-demo1 rollbar:free`
  * Create an Amazon S3 bucket to hold files for this app:
    * Ensure public access is NOT blocked (ie. uncheck the default "Block public access..." settings).
    * The AWS credentials you give to Heroku must have full R/W access to this bucket.
    * In the S3 bucket's Permissions page -> "CORS configuration" tab, enter the following CORS policy to support direct file uploads (part of the webcam recording feature), specifying your site's domain in the `AllowedOrigin` field.

  ```
  <?xml version="1.0" encoding="UTF-8"?>
  <CORSConfiguration xmlns="http://s3.amazonaws.com/doc/2006-03-01/">
  <CORSRule>
      <AllowedOrigin>https://rtl-demo1.herokuapp.com</AllowedOrigin>
      <AllowedMethod>PUT</AllowedMethod>
      <AllowedHeader>*</AllowedHeader>
  </CORSRule>
  </CORSConfiguration>
  ```

  * Copy `config/secrets.exs.sample` to `config/secrets.exs`, then fill in real values for your app environment. The AWS credentials you specify must have access to the bucket you specify.
  * Set each environment variable: `heroku config:set -a rtl-demo1 KEY=value KEY2=value2`
  * `git push rtl-demo1 master`
  * `heroku run -a rtl-demo1 "mix ecto.migrate"`
  * Add a coder: `heroku run -a rtl-demo1 "mix run priv/repo/insert_coder.exs Bob bob@gmail.com"`
  * List all available autologin URLs: `heroku run -a rtl-thrive mix login`
  * Log in as the newly-created admin, and start adding content!


### Getting videos into the database; working with multiple databases

TODO: Fill these notes in later.

In brief:

  * There's multiple ways to import videos into the database
  * There's a Youtube import script where you can provide a list of Youtube urls and the script will download each file, create a Video record for it, and upload the video & thumbnail to Youtube. But this only runs on OSX (ie your local machine), meaning you'll need to sync db state between your local dev site and a
  * In secrets.exs you could point to a deployed site's DATABASE_URL from your dev site
  * You can provide users a "record interview with my webcam" url
  * More import methods & helper features are in the works

TODO: Move these notes on the Youtube video import process into another document, they're overspecific for here

  * Make a .tsv list of Youtube videos to import. (Currently we only have a YouTube import script.) See `priv/repo/videos_import_youtube.exs` for details.
  * In your dev environment, run the Youtube importer. See `priv/repo/videos_import_youtube.exs` for details.
  * Export the videos to a dumpfile, then execute that dump in the Heroku environment. See `mix run priv/repo/videos_dump.exs`.
  * Use the scripts in `priv/repo/` to set up a database of videos and export them to the new Heroku environment
  * `heroku open`


### Reset database state:

  * `heroku pg:reset`
  * `heroku run mix ecto.migrate`
  * `heroku run mix run priv/repo/seeds.exs`
