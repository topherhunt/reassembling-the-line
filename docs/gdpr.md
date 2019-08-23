# GDPR notes

Resources:

  * https://devcenter.heroku.com/articles/gdpr
  *


## Services & entities that process RTL's user data:

  * Site is hosted on an EU Heroku instance
  * Site data is in a Heroku Postgres db
  * Files (user video recordings) are stored in an EU AWS S3 bucket
  * Site activity logs are sent to Papertrail
  * Site errors are sent to Rollbar
  * Project admin (who sends out requests to participants to submit their videos) has access to their projects' user submissions incl. recordings
  * RTL webmaster has access to all data on all projects
