#!bin/bash

set -e # crash on any error output

abort() {
  echo $1
  exit 1
}

heroku_app=( $@ )
[ -z "$heroku_app" ] && abort "Please provide a heroku app."

local_db_name="rtl_dev"

echo ""
echo "About to copy the localhost $local_db_name database to Heroku $heroku_app."
echo "The Heroku database will be backed up first."
echo "Proceed? [y/N] "
read response && [ "$response" != "y" ] && abort "User cancelled."

echo "Backing up Heroku $heroku_app database..."
heroku pg:backups:capture -a $heroku_app

echo "Copying from localhost $local_db_name to Heroku $heroku_app..."
heroku pg:reset -a $heroku_app --confirm=$heroku_app
heroku pg:push $local_db_name DATABASE_URL -a $heroku_app

echo "Done."

# Don't need any of this apparently
# heroku_db_name=$(heroku pg:info -a $heroku_app | grep "Add-on:" | head -n1 | awk '{print $2}')
# local_db_url="postgres://topher:@localhost/$local_db_name"
# heroku_db_url=$(heroku config -a $heroku_app | grep DATABASE_URL | awk '{print $2}')
# [ -z "$heroku_db_url" ] && abort "Can't get status of Heroku $heroku_app. Aborting."
# heroku_db_name=$(echo $heroku_db_url | awk -F '/' '{print $4}')
# heroku pg:copy -a $heroku_app $local_db_url DATABASE_URL --confirm=$heroku_app

# Commented out in case we want to also dump the local db while we're at it
# local_db_filename="$(date -u "+%Y-%m-%d-%H%M%S")-localhost-$local_db_name.dump"
# pg_dump $local_db_name -F c > $local_db_filename
