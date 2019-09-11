# GDPR notes

Resources:

  * https://gdprchecklist.io/
  * https://devcenter.heroku.com/articles/gdpr

Notes on our compliance:

  * All personal information we process: https://docs.google.com/spreadsheets/d/15mNVsomDdhizgNeTZWBd73wCpV7hc2rvPrnUJshwdQE/edit?usp=sharing

  * Places where we keep personal data: https://docs.google.com/spreadsheets/d/15mNVsomDdhizgNeTZWBd73wCpV7hc2rvPrnUJshwdQE/edit?usp=sharing

  * RTL does not need or have a DPO. Topher Hunt (co-founder)

  * Spreadsheet of GDPR requests: https://docs.google.com/spreadsheets/d/1LKay-nSL-WawjsGg9WdjCL_XqJwwBGb8IEg7S7kqmRU/edit#gid=0

  * Any data breach of personal data must be reported to the local authority (and to impacted users, if the data wasn't encrypted) within 72h.


## Services & entities that process RTL's user data:

  * Site is hosted on an EU Heroku instance
  * Site data is in a Heroku Postgres db
  * Files (user video recordings) are stored in an EU AWS S3 bucket
  * Site activity logs are sent to Papertrail
  * Site errors are sent to Rollbar
  * Project admin (who sends out requests to participants to submit their videos) has access to their projects' user submissions incl. recordings
  * RTL webmaster has access to all data on all projects
