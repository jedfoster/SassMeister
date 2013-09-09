module HTML
  class Pipeline
    class HamlFilter < TextFilter

      def initialize(text, context = nil, result = nil)
        super text, context, result
      end

      def call
        begin
          html = Haml::Engine.new(@text, {:suppress_eval => true}).render

          html.rstrip!
          html
        rescue Haml::Error => e
          @text = "```haml\n#{@text}\n```"

          pipe = HTML::Pipeline.new [
            HTML::Pipeline::MarkdownFilter,
            HTML::Pipeline::SanitizationFilter
          ], context

          Nokogiri.XML '<span style="background: #B4004C; color: #FFFFFF; font: 120%/1.5 \'Helvetica Neue\', Arial, sans-serif; font-weight: 200; text-shadow: 1px 1px 0 #666666; padding: 0.5em 1em;">Haml syntax error</span>'

        rescue Haml::SyntaxError => e
          Nokogiri.XML '<span style="background: #B4004C; color: #FFFFFF; font: 120%/1.5 \'Helvetica Neue\', Arial, sans-serif; font-weight: 200; text-shadow: 1px 1px 0 #666666; padding: 0.5em 1em;">Haml syntax error</span>'
        end
      end
    end
  end
end