# frozen_string_literal: true

source "https://rubygems.org"

git_source(:github) {|repo_name| "https://github.com/#{repo_name}" }

gem 'pry'
gem "sinatra"
gem 'discordrb'
gem 'activerecord'
gem 'ascii_charts'
gem 'tabulo'

if(ENV["development_phase"] == "production")
    gem 'pg'
else
    gem 'sqlite3'
end