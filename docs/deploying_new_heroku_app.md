# How to deploy this app to your own new site on Heroku

Assumes you're familiar with and set up with: Git, Heroku CLI, Elixir, and Amazon S3. See also the official guide: https://hexdocs.pm/phoenix/heroku.html

  * Clone this repository to your local machine

  * `heroku create rtl-demo1 --region eu`
  * `heroku buildpacks:add https://github.com/HashNuke/heroku-buildpack-elixir.git`
  * `heroku buildpacks:add https://github.com/gjaldon/heroku-buildpack-phoenix-static.git`
  * `heroku addons:create heroku-postgresql:hobby-dev`
  * `heroku addons:create papertrail:choklad`
  * `heroku addons:create rollbar:free`

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

  * Currently we support login via Auth0. Set up a free Auth0 tenant/application as per the instructions in the first section of https://github.com/topherhunt/cheatsheets/blob/master/elixir/howto/howto_auth0_phoenix.md. You'll give the Auth0 credentials to Heroku in the next step.

  * Copy `config/secrets.exs.sample` to `config/secrets.exs`. (This file is used in development & tests but not in production, and should never be committed to Git.)

  * In `secrets.exs`, in the comment section at bottom, there's a list of env variables that need to be set on the production site. Set them like this: `heroku config:set -a rtl-demo1 KEY=value KEY2=value2`

  * `git push rtl-demo1 master`
  * `heroku run -a rtl-demo1 "mix ecto.migrate"`
  * Add a coder: `heroku run -a rtl-demo1 "mix create_user Bob bob@gmail.com"`
  * List all available autologin URLs: `heroku run -a rtl-thrive mix login`
  * Log in as the newly-created admin, and start adding content!
