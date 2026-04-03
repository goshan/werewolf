if [ $1 = "release" ]; then
  rm -f ./public/assets/*
  RAILS_ENV=production bundle exec rake assets:precompile
elif [ $1 = "start" ]; then
  env_path="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/env"

  if [[ ! -f "$env_path" ]]; then
    echo "Error: env not found. Please create env file from env.example"
    exit 1
  fi

  bundle exec puma -p 3000 -e production -w 5 -d
fi
