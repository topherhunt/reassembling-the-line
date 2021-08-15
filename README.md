# Reassembling the Line

[![HitCount](http://hits.dwyl.com/topherhunt/reassembling-the-line.svg)](http://hits.dwyl.com/topherhunt/reassembling-the-line)

Record video interviews where people share first-hand experience on an important topic. Code each segment of the video by theme. Explore the results using a novel filterable segment playback UI. Built by Whitney Hunter-Thomson and [Topher Hunt](topherhunt.com).

Check out the demo to see more: [https://rtl-demo1.herokuapp.com](https://rtl-demo1.herokuapp.com)

If you're using this project, **please let us know** so we can learn what works well and how we can improve it! Our goal is to spread this concept as quickly as possible, and we can only do that with your feedback and input.


## Setting up the dev environment

  * Ensure Erlang, Kiex, Elixir (version in `mix.exs`), and Node are installed
  * `mix deps.get`
  * `npm install`
  * `mix ecto.reset`
  * `mix run scripts/seeds.exs`
  * `MIX_ENV=test mix ecto.reset`


## Running the app

  * `mix test` (be sure to start `chromedriver` in another tab first)
  * `mix phoenix.server`
  * `mix run priv/repo/autologins.exs` - list all autologin URLs


## Importing videos

I've written scripts to help with batch importing videos from YouTube. Here's how to use them:

  * Prepare a spreadsheet of YouTube video URLs to import. Each row should have two columns: the human-readable title, and the YouTube URL to download from. Save it as `import_youtube_videos.tsv`.
  * `mix run priv/repo/import_youtube_videos.exs` - This script downloads each video from YouTube, uploads the recording and thumbnail to S3, and inserts the record into the local database. See the source code comments for requirements and details.
  * `mix run priv/repo/export_videos_to_dump.exs` - This script exports the local database of Videos to an executable dump which you can run elsewhere to create those same Video records in another environment.


## I18n / translation

Most user-visible text in this app is translated using gettext. See https://github.com/topherhunt/cheatsheets/blob/master/elixir/howto/gettext_i18n.md for usage tips.

Brief steps for syncing translations:

  - `mix gettext.extract`
  - `mix gettext.merge priv/gettext/`
  - Review all translations marked "fuzzy": edit if needed, then remove the fuzzy label
  - Commit changes to Git with message "Sync translations"
  - `ruby ~/Sites/personal/utilities/machine_translate.rb priv/gettext/nl/LC_MESSAGES/default.po en nl`
  - `git diff` to review & adjust all machine translations
  - Commit changes to Git with message "NL machine translations"


## Test

  * A current version of ChromeDriver must be running in order for integration tests to pass.


## Production

Deploy to production:

  * `git push rtl-prod master`
  * `heroku run -a rtl-prod mix ecto.migrate`

Run an iex console on the server:

    heroku run -a rtl-prod "POOL_SIZE=2 iex -S mix"

Register a new user:

  * `heroku run -a rtl-prod iex -S mix`
  * `RTL.Accounts.insert_user!(%{name: "Elmer Fudd", email: "elmer.fudd@gmail.com"})`

Get the link to force login as a registered user:

    heroku run mix login hunt.topher@gmail.com


More documentation at: https://hexdocs.pm/phoenix/heroku.html


## Data privacy

  * See `docs/gdpr.md`.


## Other docs & tasks

See also:

  * `docs/migrating_s3_data.md`
  * `docs/deploying_new_heroku_app.md`


### Reset database state:

  * `heroku pg:reset`
  * `heroku run mix ecto.migrate`
  * `heroku run mix run priv/repo/seeds.exs`
