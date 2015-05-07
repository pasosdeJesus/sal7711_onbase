# encoding: UTF-8
ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../../Gemfile', __FILE__)

ENV['RACK_MULTIPART_LIMIT'] = '2048'

require 'bundler/setup' # Set up gems listed in the Gemfile.
