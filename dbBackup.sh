rm latest.dump
heroku login -i
heroku pg:backups:capture -a irinasweet
heroku pg:backups:download -a irinasweet
pg_restore --verbose --clean --no-acl --no-owner -h localhost -d irina_sweetshop_on_rails_development latest.dump


# Token:       HRKU-819e6fdd-7ae5-4c56-ab24-b36d280d6725