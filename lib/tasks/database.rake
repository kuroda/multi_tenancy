namespace :db do
  desc "Restore database"
  task :restore => :environment do
    sh "bin/rails db:environment:set RAILS_ENV=migrator"
    sh "bin/rails db:migrate:reset RAILS_ENV=migrator DB_USERNAME=mt"
    sh "bin/rails runner db/scripts/grant_privileges.rb"
    sh "bin/rails db:seed RAILS_ENV=migrator"
  end
end
