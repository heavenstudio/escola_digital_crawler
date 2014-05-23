# Escola Digital Crawler
## Objective
To find and save all of EscolaDigital's articles into a MongoDB database

## Instalation
You must have Ruby 2.1.1 installed (or at least a version greater then 1.9) and also bundler (`gem install bundler`). Simply open this folder with a terminal application and run `bundle install` to install all required dependencies.

## Usage
Alter the mongoid.yml file with you corresponding database options and then run `bundle exec ruby main.rb`. Finally, run `VVERBOSE=1 TERM_CHILD=1 QUEUE=crawler COUNT=10 bundle exec rake resque:workers` to create your crawlers.
