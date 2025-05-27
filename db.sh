rm latest.dump
heroku login
heroku pg:backups:capture -a irinasweet
heroku pg:backups:download -a irinasweet
pg_restore --verbose --clean --no-acl --no-owner -h localhost -d irina_sweetshop_on_rails_development latest.dump

