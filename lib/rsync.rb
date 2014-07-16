require "rsync/version"
require "rsync/command"
require "rsync/result"
require 'rsync/configure'

require "string"

# The main interface to rsync
module Rsync
  extend Configure
  # Creates and runs an rsync {Command} and return the {Result}
  # @param source {String}
  # @param destination {String}
  # @param args {Array}
  # @return {Result}
  # @yield {Result}
  def self.run(source, destination, args = [], &block)
    source = source.quoted unless source.quoted?
    destination = "#{self.host}:#{destination}" if self.host
    destination = destination.quoted unless destination.quoted?
    result = Command.run(source, destination, args)
    yield(result) if block_given?
    result
  end
end
