app: bundle exec thin -C config/thin.yml -R config.ru start
worker: bundle exec sidekiq -r ./config/workers.rb -d
