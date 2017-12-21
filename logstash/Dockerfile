# https://github.com/elastic/logstash-docker
FROM docker.elastic.co/logstash/logstash-oss:6.1.1

# Add your logstash plugins setup here
# Example: RUN logstash-plugin install logstash-filter-json

RUN DEBUG=1 logstash-plugin install logstash-input-beats || (sed -i '/username><\//d' ~/.m2/settings.xml && sed -i '/password><\//d' ~/.m2/settings.xml && logstash-plugin install logstash-input-beats)

ENV LOGSTASH_PATH /usr/share/logstash
ENV PATH $LOGSTASH_PATH/vendor/jruby/bin:$PATH

RUN gem install bundler

ADD logstash-filter-sparql $LOGSTASH_PATH/logstash-filter-sparql
USER root
RUN chown -R logstash: $LOGSTASH_PATH/logstash-filter-sparql
USER logstash

RUN	cd $LOGSTASH_PATH/logstash-filter-sparql && \
	bundle install && \
	TEST_DEBUG=1 bundle exec rspec && \
	gem build logstash-filter-sparql.gemspec && \
	DEBUG=1 logstash-plugin install logstash-filter-sparql-*.gem