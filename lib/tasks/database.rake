namespace :db do
  desc "Restore database"
  task :restore => :environment do
    sh "bin/rails db:environment:set RAILS_ENV=development"
    sh "bin/rails db:migrate:reset"
    sh "bin/rails db:seed"
  end
end
