require "test/unit"
require "isolate-autorequire"

class TestIsolateAutorequire < Test::Unit::TestCase
  Entry = Struct.new(:name, :options)

  def test_sanity
    entry = Entry.new("non_existent_library", {})
    out, err = capture_io do
      IsolateAutorequire.new([entry]).now!
    end
    assert out.empty?
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
