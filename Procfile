worker: bundle exec sidekiq -C ./config/sidekiq.yml -r ./config/workers.rb -d
app: bundle exec thin -C config/thin.yml -R config.ru start
