FROM ruby:3.2.3

WORKDIR /app

RUN apt-get update -qq && apt-get install -y build-essential nodejs

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY . .

ENV RAILS_ENV=production

RUN bundle exec rails assets:precompile

CMD ["sh", "-c", "rm -f tmp/pids/server.pid && bundle exec rails server -b 0.0.0.0 -p ${PORT:-3000}"]
