require "test/unit"
require "text_bringer/buffer"

class TestBuffer < Test::Unit::TestCase
  include TextBringer

  def test_delete_char_forward
    buffer = Buffer.new
    buffer.insert("abc")
    buffer.backward_char(1)
    buffer.delete_char
    assert_equal("ab", buffer.to_s)
    assert_equal(2, buffer.point)
  end

  def test_delete_char_backward
    buffer = Buffer.new
    buffer.insert("abc")
    buffer.backward_char(1)
    buffer.delete_char(-1)
    assert_equal("ac", buffer.to_s)
    assert_equal(1, buffer.point)
  end

  def test_delete_char_at_eob
    buffer = Buffer.new
    buffer.insert("abc")
    assert_raise(RangeError) do
      buffer.delete_char
    end
    assert_equal("abc", buffer.to_s)
    assert_equal(3, buffer.point)
  end

  def test_delete_char_over_eob
    buffer = Buffer.new
    buffer.insert("abc")
    buffer.backward_char(2)
    assert_raise(RangeError) do
      buffer.delete_char(3)
    end
    assert_equal("abc", buffer.to_s)
    assert_equal(1, buffer.point)
  end

  def test_delete_char_at_bob
    buffer = Buffer.new
    buffer.insert("abc")
    buffer.beginning_of_buffer
    assert_raise(RangeError) do
      buffer.delete_char(-1)
    end
    assert_equal("abc", buffer.to_s)
    assert_equal(0, buffer.point)
  end

  def test_delete_char_over_bob
    buffer = Buffer.new
    buffer.insert("abc")
    buffer.backward_char(1)
    assert_raise(RangeError) do
      buffer.delete_char(-3)
    end
    assert_equal("abc", buffer.to_s)
    assert_equal(2, buffer.point)
  end
end