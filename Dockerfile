FROM ruby:3.2.3
RUN apt-get update -qq && apt-get install -y nodejs postgresql-client
WORKDIR /voicegen
COPY Gemfile* ./
RUN bundle install
COPY . .
RUN bin/rails assets:precompile assets:clean
CMD ["sh", "-c", "rm -f tmp/pids/server.pid && bin/rails server -b 0.0.0.0"]
