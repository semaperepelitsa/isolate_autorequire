require "isolate"

class IsolateAutorequire
  VERSION = '0.1.0'

  def initialize(entries = Isolate.sandbox.entries)
    @entries = entries
  end

  def now!
    @entries.each do |e|
      next unless path = e.options.fetch(:require, e.name)

      begin
        require path
      rescue LoadError
        warn "cannot require #{path.inspect}"
      end

    end
  end

  def self.now!
    new.now!
  end
end
