# webpacker: NODE_ENV=production ./bin/webpack --watch --colors --progress
webpack: bundle exec bin/webpack-dev-server
web: bundle exec rails server -p 3000
jobs: bundle exec sidekiq -C ./config/sidekiq.yml
css: yarn build:css --watch