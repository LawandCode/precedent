# encoding: utf-8
# Autogenerated from a Treetop grammar. Edits may be lost.


module Precedent
  module Heading
    include Treetop::Runtime

    def root
      @root ||= :heading
    end

    module Heading0
      def hashes
        elements[0]
      end

      def content
        elements[2]
      end
    end

    module Heading1
      def build
        {
          :type => :heading,
          # depth is the number of '#'s
          :level => hashes.text_value.length,
          :content => content.build
        }
      end
    end

    def _nt_heading
      start_index = index
      if node_cache[:heading].has_key?(index)
        cached = node_cache[:heading][index]
        if cached
          cached = SyntaxNode.new(input, index...(index + 1)) if cached == true
          @index = cached.interval.end
        end
        return cached
      end

      i0, s0 = index, []
      s1, i1 = [], index
      loop do
        if has_terminal?('#', false, index)
          r2 = instantiate_node(SyntaxNode,input, index...(index + 1))
          @index += 1
        else
          terminal_parse_failure('#')
          r2 = nil
        end
        if r2
          s1 << r2
        else
          break
        end
      end
      if s1.empty?
        @index = i1
        r1 = nil
      else
        r1 = instantiate_node(SyntaxNode,input, i1...index, s1)
      end
      s0 << r1
      if r1
        s3, i3 = [], index
        loop do
          if has_terminal?(' ', false, index)
            r4 = instantiate_node(SyntaxNode,input, index...(index + 1))
            @index += 1
          else
            terminal_parse_failure(' ')
            r4 = nil
          end
          if r4
            s3 << r4
          else
            break
          end
        end
        if s3.empty?
          @index = i3
          r3 = nil
        else
          r3 = instantiate_node(SyntaxNode,input, i3...index, s3)
        end
        s0 << r3
        if r3
          r5 = _nt_inline
          s0 << r5
        end
      end
      if s0.last
        r0 = instantiate_node(SyntaxNode,input, i0...index, s0)
        r0.extend(Heading0)
        r0.extend(Heading1)
      else
        @index = i0
        r0 = nil
      end

      node_cache[:heading][start_index] = r0

      r0
    end

  end

  class HeadingParser < Treetop::Runtime::CompiledParser
    include Heading
  end

end
