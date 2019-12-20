# Development setup

## Environment

- Ruby

```
$ ruby -v
ruby 2.3.3p222
 ```

- Rails

```
$ rails -v
Rails 5.0.7
```

- Bundler

```
$ bundle -v
Bundler version 2.0.1
```

## Setup

- Provision

```
$ cd werewolf
$ bundle install --path=vendor/bundle
```

- Database

setup your database config in config/database.yml

default is `mysql -hlocalhost:3306 -uroot` (no pass)

- Database migration

```
$ cd werewolf
$ bundle exec rake db:create
$ bundle exec rake db:migrate
$ bundle exec rake db:seed
```

- Run development server in localhost

```
$ cd werewolf
$ bundle exec rails server
(then access http://localhost:3000 by any browser)
```

