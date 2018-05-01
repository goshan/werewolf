if [ $1 = "release" ]; then
	rm -f ./public/assets/*
	RAILS_ENV=production bundle exec rake assets:precompile
elif [ $1 = "start" ]; then
	rbenv sudo bundle exec puma -p 80 -e production -w 5
fi
