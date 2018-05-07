if [ $1 = "release" ]; then
	rm -f ./public/assets/*
	RAILS_ENV=production bundle exec rake assets:precompile
elif [ $1 = "start" ]; then
	rbenv sudo DB_HOST=$DB_HOST DB_USER=$DB_USER DB_PASS=$DB_PASS CACHE_HOST=$CACHE_HOST bundle exec puma -p 80 -e production -w 5
fi
