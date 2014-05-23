require 'bundler'
Bundler.setup

require 'mongo'
require 'yaml'
require 'resque'
require 'nokogiri'
require 'open-uri'

require_relative 'crawlers/article_crawler'
require_relative 'crawlers/articles_on_page_crawler'
require_relative 'crawlers/number_of_pages_crawler'
