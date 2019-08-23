# Steps for migrating data to a new S3 bucket

I'm documenting this in case I need to do something similar again in the future.

These steps work by syncing the production database to your local machine, then you run commands locally to download and then upload all referenced S3 files to their new home. We're assuming that the production _site_ and _database_ are remaining constant, and that only the S3 files must be moved.


## The steps

  * Put the production site into maintenance mode.

  * In `secrets.exs`, configure your dev app to connect to the "old" S3 bucket. You'll need to change three env vars: S3_BUCKET, S3_REGION, and S3_HOST.

  * Copy the production db to your local dev db. Example commands:
    - `heroku pg:backups:capture -a rtl-prod`
    - `heroku pg:backups:download -a rtl-prod`
    - `pg_restore --verbose --clean --no-acl --no-owner -h localhost -U topher -d rtl_dev latest.dump`
    - `rm latest.dump`

  * `mix run scripts/s3_download_linked.exs` (download all referenced S3 files)

  * In `secrets.exs`, configure your dev app to connect to the "new" S3 bucket.

  * `mix run scripts/s3_upload_linked.exs` (upload all referenced files to the new bucket)

  * Start the local app. Log in as an admin and browse around. Confirm that your local app is correctly displaying images & movies that are linking from the new bucket. Also confirm that you can record a new video, and that is browser-uploaded to the new bucket and is viewable in the admin coding UI.

  * Update the production site's env vars to point to the new S3 bucket.

  * Take the production site out of maintenance mode. Restart it.

  * Log into the production site as an admin. Confirm that you can view images & videos, that they're linked from the correct (new) bucket, and that you can upload new recordings to that bucket.
