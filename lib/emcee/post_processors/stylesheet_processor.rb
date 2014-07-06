require 'uri'

module Emcee
  module PostProcessors
    # StylesheetProcessor scans a document for external stylesheet references and
    # inlines them into the current document.
    class StylesheetProcessor
      def initialize(context)
        @context = context
        @directory = File.dirname(context.pathname)
      end

      def process(data)
        doc = Hpricot(data)
        inline_styles(doc)
        doc.to_html.lstrip
      end

      private

      def inline_styles(doc)
        doc.search("//link[@rel='stylesheet']").each do |node|
          path = absolute_path(node.attributes["href"])
          content = @context.evaluate(path)
          style = create_style(content)
          node.swap(style)
        end
      end

      def absolute_path(path)
        File.absolute_path(path, @directory)
      end

      def create_style(content)
        node = Hpricot::Elem.new("style")
        node.inner_html = content
        node.to_html
      end
    end
  end
end
