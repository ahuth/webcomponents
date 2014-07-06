require 'uri'

module Emcee
  module PostProcessors
    # ScriptProcessor scans a document for external script references and inlines
    # them into the current document.
    class ScriptProcessor
      def initialize(context)
        @context = context
        @directory = File.dirname(context.pathname)
      end

      def process(data)
        doc = Hpricot(data)
        inline_scripts(doc)
        doc.to_html.lstrip
      end

      private

      def inline_scripts(doc)
        doc.search("//script[@src]").each do |node|
          path = absolute_path(node.attributes["src"])
          content = @context.evaluate(path)
          script = create_script(content)
          node.swap(script)
        end
      end

      def absolute_path(path)
        File.absolute_path(path, @directory)
      end

      def create_script(content)
        node = Hpricot::Elem.new("script")
        node.inner_html = content
        node.to_html
      end
    end
  end
end
