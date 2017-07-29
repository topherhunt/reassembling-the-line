# EducateYour

## Running the app

  * `mix phoenix.server`

## Importing videos

I've written scripts to help with batch importing videos from YouTube. Here's how to use them:

  * Prepare a spreadsheet of YouTube video URLs to import. Each row should have two columns: the human-readable title, and the YouTube URL to download from. Save it as `import_youtube_videos.tsv`.
  * `mix run priv/repo/import_youtube_videos.exs` - This script downloads each video from YouTube, uploads the recording and thumbnail to S3, and inserts the record into the local database. See the source code for comments on prerequisites.
  * `mix run priv/repo/export_videos_to_dump.exs` - This script exports the local database of Videos to an executable dump which you can run elsewhere to create those same Video records in another environment.

## Test

  * Run `phantomjs --wd` before running `mix test` (integration tests require this service to be running)

## Heroku

### Reset database state:

- `heroku pg:reset`
- `heroku run mix ecto.migrate`
- `heroku run mix run priv/repo/seeds.exs`
