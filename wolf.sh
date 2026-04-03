if [ $1 = "release" ]; then
  rm -f ./public/assets/*
  RAILS_ENV=production bundle exec rake assets:precompile
elif [ $1 = "start" ]; then
  bundle exec puma -p 3000 -e production -w 5 -d
fi
