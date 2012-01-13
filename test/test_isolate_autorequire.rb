require "test/unit"
require "isolate_autorequire"

class TestIsolateAutorequire < Test::Unit::TestCase
  Entry = Struct.new(:name, :options, :environments) do
    def matches?(env)
      environments.map(&:to_s).include?(env)
    end
  end

  def test_sanity
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
