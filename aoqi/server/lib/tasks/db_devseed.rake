namespace :db do
  task :devseed => :environment do
    Dir.glob("#{Rails.root}/app/models/**/*rb").each{|m|
      require m 
    }

    # clear database
    ActiveRecord::Base.send(:subclasses).each do |klass|
      klass.delete_all
    end

    seed_file = "#{Rails.root}/db/devseeds.rb"
    load(seed_file) if File.exist?(seed_file)
  end

  task :devreset => :environment do
    Rake::Task["db:drop"].invoke
    Rake::Task["db:create"].invoke
    Rake::Task["db:migrate"].invoke
    Rake::Task["db:devseed"].invoke
  end
end
