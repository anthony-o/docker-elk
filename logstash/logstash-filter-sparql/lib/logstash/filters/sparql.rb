# encoding: utf-8
require "logstash/filters/base"
require "logstash/namespace"

require "sparql"

# Coded following https://www.elastic.co/guide/en/logstash/current/_how_to_write_a_logstash_filter_plugin.html

# This  filter will replace the contents of the default 
# message field with whatever you specify in the configuration.
#
# It is only intended to be used as an .
class LogStash::Filters::Sparql < LogStash::Filters::Base

  # Setting the config_name here is required. This is how you
  # configure this filter from your Logstash config.
  #
  # filter {
  #    {
  #     message => "My message..."
  #   }
  # }
  #
  config_name "sparql"
  
  # catching the error, inspired by https://github.com/logstash-plugins/logstash-filter-ruby/blob/c2a292c0cad33369731eed5feb7a3820f74a3762/lib/logstash/filters/ruby.rb#L102
  config :tag_on_exception, :type => :string, :default => "_exception"
  

  public
  def register
    # Add instance variables 
  end # def register

  public
  def filter(event)
    begin
      request = event.get("message")
      if request.start_with?("sparql_query:")
        sparql_query = request["sparql_query:".length..-1]
      end
      if sparql_query
        event.set("sparql_query", sparql_query)
        parsed_query = SPARQL::Grammar.parse(sparql_query, {:resolve_iris => TRUE})
        event.set("parsed_sparql_query", parsed_query.to_sse.strip)
      end
    
      # filter_matched should go in the last line of our successful code
      filter_matched(event)
    
    rescue => e
      # catching the error, inspired by https://github.com/logstash-plugins/logstash-filter-ruby/blob/c2a292c0cad33369731eed5feb7a3820f74a3762/lib/logstash/filters/ruby.rb#L102
      event.tag(@tag_on_exception)
      message = "Problem in sparql filter: " + e.message
      @logger.error(message, :class => e.class.name,
                             :backtrace => e.backtrace)
      
      event.set("exception", "'#{e.inspect}' at #{e.backtrace}")
      return event
    end
  end # def filter
end # class LogStash::Filters::Sparql
