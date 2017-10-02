FROM ruby
RUN mkdir /code
WORKDIR /code

RUN gem install bundler
ADD Gemfile .
RUN bundle install
ADD . .
