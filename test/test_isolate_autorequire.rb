require "test/unit"
require "isolate_autorequire"

module Isolate
  def self.env
    "development"
  end
end

class TestIsolateAutorequire < Test::Unit::TestCase
  Entry = Struct.new(:name, :options, :environments) do
    def matches?(env)
      environments.empty? or environments.map(&:to_s).include?(env)
    end
  end

  def test_requiring_appropriate_env
    entries = [
      Entry.new("non_existent_library", {}, [:development]),
      Entry.new("very_productive_gem", {}, [:production])
    ]
    out, err = capture_io do
      IsolateAutorequire.new(entries).now!(:development)
    end
    assert_equal "", out
    assert_equal 'cannot require "non_existent_library"', err.chomp
  end

  def test_custom_require_path
    entries = [
      Entry.new("non_existent_library", { :require => "non_existent_library/path" }, []),
    ]
    out, err = capture_io do
      IsolateAutorequire.new(entries).now!
    end
    assert_equal "", out
    assert_equal 'cannot require "non_existent_library/path"', err.chomp
  end

  def test_custom_no_require
    entries = [
      Entry.new("non_existent_library", { :require => false }, []),
    ]
    out, err = capture_io do
      IsolateAutorequire.new(entries).now!
    end
    assert_equal "", out
    assert_equal '', err.chomp
  end

private

  # thanks, minitest
  def capture_io
    require 'stringio'

    orig_stdout, orig_stderr         = $stdout, $stderr
    captured_stdout, captured_stderr = StringIO.new, StringIO.new
    $stdout, $stderr                 = captured_stdout, captured_stderr

    yield

    return captured_stdout.string, captured_stderr.string
  ensure
    $stdout = orig_stdout
    $stderr = orig_stderr
  end

end
