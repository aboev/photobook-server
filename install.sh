# Ubuntu 14.04
echo '=== 1. Installing prerequisites ==='
sudo apt-get install imagemagick
sudo apt-get install libmagickwand-dev imagemagick
sudo apt-get install postgresql postgresql-contrib
sudo apt-get install libpq-dev
sudo apt-get install redis-server

echo '=== 2. Installing Ruby on Rails ==='

sudo apt-get install git-core curl zlib1g-dev build-essential libssl-dev libreadline-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt1-dev libcurl4-openssl-dev python-software-properties libffi-dev nodejs
cd
git clone https://github.com/rbenv/rbenv.git ~/.rbenv
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
echo 'eval "$(rbenv init -)"' >> ~/.bashrc
exec $SHELL

git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build
echo 'export PATH="$HOME/.rbenv/plugins/ruby-build/bin:$PATH"' >> ~/.bashrc
exec $SHELL

rbenv install 2.3.1
rbenv global 2.3.1
ruby -v
curl -sL https://deb.nodesource.com/setup_4.x | sudo -E bash -
sudo apt-get install -y nodejs
gem install rails -v 4.1.1
rbenv rehash

echo '=== 3. Installing photobook-server (refer to comments in install.sh)  ==='

# set values in config/config.yml & config/database.yml
# update line in Gemfile: gem ‘attr_encrypted', ‘1.3.5'
# add line in config.yml: db_enc_key [arbitrary encryption key]
# rename config/secrets.yml.example -> config/secrets.yml 
# set values in config/secrets.yml from output of command: RAILS_ENV=production rake secret
# change line in config/environments/production.rb to: config.serve_static_assets = true

mkdir public/uploads
bundle install

# change line in /etc/postgresql/9.3/main/pg_hba.conf «local all postgres peer -> trust»

rake db:setup RAILS_ENV=development
rake db:setup RAILS_ENV=production
rake db:setup RAILS_ENV=test

rake test

