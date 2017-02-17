# frozen_string_literal: true

module Textbringer
  class ProgrammingMode < FundamentalMode
    # abstract mode
    undefine_command(:programming_mode)

    define_generic_command :indent_line
    define_generic_command :newline_and_reindent
    define_generic_command :forward_definition
    define_generic_command :backward_definition
    define_generic_command :compile
    define_generic_command :toggle_test

    PROGRAMMING_MODE_MAP = Keymap.new
    PROGRAMMING_MODE_MAP.define_key("\t", :indent_line_command)
    PROGRAMMING_MODE_MAP.define_key("\C-m", :newline_and_reindent_command)
    PROGRAMMING_MODE_MAP.define_key("\C-c\C-n", :forward_definition_command)
    PROGRAMMING_MODE_MAP.define_key("\C-c\C-p", :backward_definition_command)
    PROGRAMMING_MODE_MAP.define_key("\C-c\C-c", :compile_command)
    PROGRAMMING_MODE_MAP.define_key("\C-c\C-t", :toggle_test_command)

    def initialize(buffer)
      super(buffer)
      buffer.keymap = PROGRAMMING_MODE_MAP
    end

    # Return true if modified.
    def indent_line
      result = false
      level = calculate_indentation
      return result if level.nil?
      @buffer.save_excursion do
        @buffer.beginning_of_line
        has_space = @buffer.looking_at?(/[ \t]+/)
        if has_space
          s = @buffer.match_string(0)
          break if /\t/ !~ s && s.size == level
          @buffer.delete_region(@buffer.match_beginning(0),
                                @buffer.match_end(0))
        else
          break if level == 0
        end
        @buffer.indent_to(level)
        if has_space
          @buffer.merge_undo(2)
        end
        result = true
      end
      pos = @buffer.point
      @buffer.beginning_of_line
      @buffer.forward_char while /[ \t]/ =~ @buffer.char_after
      if @buffer.point < pos
        @buffer.goto_char(pos)
      end
      result
    end

    def newline_and_reindent
      n = 1
      if indent_line
        n += 1
      end
      @buffer.save_excursion do
        pos = @buffer.point
        @buffer.beginning_of_line
        if /\A[ \t]+\z/ =~ @buffer.substring(@buffer.point, pos)
          @buffer.delete_region(@buffer.point, pos)
          n += 1
        end
      end
      @buffer.insert("\n")
      if indent_line
        n += 1
      end
      @buffer.merge_undo(n) if n > 1
    end

    private

    def calculate_indentation
      raise EditorError, "indent_line is not defined in the current mode"
    end
  end
end
