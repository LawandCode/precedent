# encoding: UTF-8

require_relative 'grammar/node_patch'
require_relative 'grammar/inline'

module Precedent
  class Parser
    # cached instance of the parser for inline elements
    @@inline_parser = InlineParser.new

    def parse(input)
      post_process(parse_blocks(input))
    end

    def post_process(raw_hash)
      raw_blocks = raw_hash.delete(:blocks)
      document_blocks = raw_blocks.reduce(
        body: [], footnotes: []
      ) do |mem, block|
        content = block[:content]
        if content
          ast = @@inline_parser.parse(content.join(' ').gsub(/ +/, ' '))
          if ast.nil?
            puts content
          end
          block.merge!(content: ast.build)
        end

        type = block[:type]
        if [:footnote, :indented_footnote, :flush_footnote].include?(type)
          mem[:footnotes] << block
        else
          mem[:body] << block
        end
        mem
      end
      raw_hash.merge(document_blocks)
    end

    def build_block(type, first_content=nil)
      if first_content
        { :type => type, :content => [first_content] }
      else
        { :type => type }
      end
    end

    BLANK_LINE = /^\s*$/
    COMMENT_LINE = /^%/
    FLUSH_LINE = /^([^ ].+)$/
    FLUSH_QUOTE = /^    (.+)$/
    INDENTED_FOOTNOTE = /^  \^\s([^\s].+)$/
    FLUSH_FOOTNOTE = /^\^\s([^\s].+)$/
    START_FOOTNOTE = /^\^([^\s]+)\s+([^\s].+)$/
    HEADING = /^(#+)\s+(.+)$/
    INDENTED = /^  (.+)$/
    INDENTED_QUOTE = /^      (.+)$/
    IMAGE_TAG = /^\[\[IMAGE: ([0-9a-zA-Z\-_]+)\]\]$/
    METADATA = /^([A-Z][[:ascii:]]*): (.+)$/
    CENTERED = /^        (.+)$/
    RAGGED_LEFT = /^          (.+)$/
    RULE_BODY = /^\* \* \*\s*$/
    RULE_QUOTE = /^    \* \* \*\s*$/

    def parse_blocks(input)
      block_ended = false
      meta_ended = false

      blocks = []
      meta = {}
      out = {:meta => meta, :blocks => blocks}

      input.lines.each do |line|
        line.chomp!
        if BLANK_LINE =~ line
          block_ended = true
          meta_ended = true
        elsif COMMENT_LINE =~ line # skip
        elsif METADATA =~ line && !meta_ended
          meta[$1.downcase.to_sym] = meta_value($2)
        elsif block_ended || blocks.empty?
          # Start a new block-level element
          start_block(blocks, line)
          block_ended = false
        else
          blocks.last[:content] << line
        end
      end

      out
    end

    def start_block(blocks, line)
      case line
      when IMAGE_TAG
        blocks << build_block(:image).merge(file: $1)
      when RULE_QUOTE
        blocks << build_block(:rule_quote)
      when RULE_BODY
        blocks << build_block(:rule)
      when HEADING
        blocks << build_block(:heading, $2).merge(level: $1.length)
      when START_FOOTNOTE
        blocks << build_block(:footnote, $2).merge(marker: $1)
      when FLUSH_FOOTNOTE
        blocks << build_block(:flush_footnote, $1)
      when INDENTED_FOOTNOTE
        blocks << build_block(:indented_footnote, $1)
      when RAGGED_LEFT
        blocks << build_block(:ragged_left, $1)
      when CENTERED
        blocks << build_block(:centered, $1)
      when INDENTED_QUOTE
        blocks << build_block(:indented_quote, $1)
      when FLUSH_QUOTE
        blocks << build_block(:flush_quote, $1)
      when INDENTED
        blocks << build_block(:indented, $1)
      else # Flush
        blocks << build_block(:flush, line)
      end
    end

    def meta_value(value)
      v = value.strip
      case v
      when /^\d+$/ then v.to_i
      when /^\d\d\d\d-\d\d-\d\d$/ then Date.parse(v)
      when /^true|yes$/i then true
      when /^false|no$/i then false
      else v
      end
    end
  end
end
