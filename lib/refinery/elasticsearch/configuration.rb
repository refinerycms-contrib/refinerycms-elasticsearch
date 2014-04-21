require 'logger'

module Refinery
  module Elasticsearch
    include ActiveSupport::Configurable

    config_accessor :es_host, :es_port, :es_log, :es_logger

    self.es_host = 'localhost'
    self.es_port = 9200
    self.es_log = false
    self.es_logger = Logger.new(STDOUT)
  end
end
