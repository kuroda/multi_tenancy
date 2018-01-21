#!/usr/bin/env ruby

require "yaml"

env = ENV["RAILS_ENV"] || "development"
path = File.expand_path("../../../config/database.yml", __FILE__)
configurations = YAML.load_file(path)

config = configurations[env]

statements = %Q{
  ALTER USER #{config['username']} WITH PASSWORD '#{config['password']}';

  GRANT SELECT, INSERT, UPDATE, DELETE
  ON ALL TABLES IN SCHEMA public
  TO #{config['username']}
}.gsub(/\s+/, ' ').strip

config = configurations["migrator"]

command = %Q{
  PGPASSWORD=#{config['password']} psql -U #{config['username']} --quiet
  --host=#{config['host']} --port=#{config['port']}
  #{config['database']} -c "#{statements}"
}.gsub(/\s+/, ' ').strip

system(command)
