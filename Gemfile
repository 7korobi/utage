source 'https://rubygems.org'
ruby "2.5.1"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw]

gem "nokogiri"

gem "rails"
gem 'sinatra', require: false
gem 'sidekiq'
gem 'sidekiq-cron'

# data_base
# yum install mongo-10gen mongo-10gen-server
# yum install redis
gem 'mongoid'
gem "paperclip"
gem 'redis-namespace'

# javascript
# See https://github.com/sstephenson/execjs#readme for more supported runtimes
gem 'therubyracer', platforms: :ruby
gem "bson_ext"
gem 'oj'

# control support
gem "moji"
gem "jpmobile"

group :development do
  gem "aws-sdk"

# To use debugger
  gem 'pry'
  gem 'pry-byebug'
  gem 'pry-stack_explorer'
  gem 'better_errors'
  gem 'binding_of_caller'
end
