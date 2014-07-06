require 'uri'

module Emcee
  module PostProcessors
    # ImportProcessor scans a file for html imports and adds them to the current
    # required assets.
    class ImportProcessor
      def initialize(context)
        @context = context
        @directory = File.dirname(context.pathname)
      end

      def process(data)
        doc = Hpricot(data)
        require_assets(doc)
        remove_imports(doc)
        doc.to_html.lstrip
      end

      private

      def require_assets(doc)
        doc.search("//link[@rel='import']").each do |node|
          path = File.absolute_path(node.attributes["href"], @directory)
          @context.require_asset(path)
        end
      end

      def remove_imports(doc)
        doc.search("//link[@rel='import']").each do |node|
          node.swap('')
        end
      end
    end
  end
end
