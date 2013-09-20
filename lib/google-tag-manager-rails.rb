module GoogleTagManager
  PLACEHOLDER_GTM_ID = "GTM-XXXX"

  class << self
    def valid_gtm_id?
      !(gtm_id.blank? || gtm_id == PLACEHOLDER_GTM_ID || (gtm_id =~ /^GTM-/).nil?)
    end

    def gtm_id
      @@gtm_id ||= PLACEHOLDER_GTM_ID
    end

    def gtm_id=(gtm_id)
      @@gtm_id = gtm_id
    end
  
    def to_html
      data_layer_tag + "\n" + container_tag
    end


    def method_missing(name, *args)
      if args.size == 1 and name =~ /^(.+)=/
        new_variable = $1.to_sym
        data_layer_hash[new_variable] = args.first
        self.class.instance_eval do
          define_method new_variable do
            data_layer_hash[new_variable]
          end
        end
      else
        super
      end
    end

    private
      def data_layer_hash
        @@data_layer_hash ||= {}
      end

      def data_layer_tag
        "<script>dataLayer = [#{serialize data_layer_hash}]</script>"
      end
      
      # This helper serialize data into array and hahes in JS
      def serialize data
        if data.is_a? Hash
          # If this is a hash we serialze it in hash syntax: {key1: value1, key2:value2...}
          "{#{data.map do |key, value|
              "'#{key}': #{serialize(value)}"
            end.join(",")
            } }"
        elsif data.is_a? Array
          # If it's an array we just join the elements serialized: [element1, element2, element3...]
          "[#{data.map{|d| serialize(d)}.join(',')}]"
        else
          # And if it's a simple element, we turn it into a string
          "'#{data.to_s.gsub(/'/){|match| "\\'"}}'"
        end
    
      end

      def container_tag
        <<-HTML
<!-- Google Tag Manager -->
<noscript><iframe src="//www.googletagmanager.com/ns.html?id=#{gtm_id}" height="0" width="0" style="display:none;visibility:hidden"></iframe></noscript>
<script>(function(w,d,s,l,i){w[l]=w[l]||[];w[l].push({'gtm.start': new Date().getTime(),event:'gtm.js'});var f=d.getElementsByTagName(s)[0], j=d.createElement(s),dl=l!='dataLayer'?'&l='+l:'';j.async=true;j.src='//www.googletagmanager.com/gtm.js?id='+i+dl;f.parentNode.insertBefore(j,f);})(window,document,'script','dataLayer','#{gtm_id}');</script>
<!-- End Google Tag Manager -->
        HTML
      end
  end

end
if defined?(Rails)
  require 'google-tag-manager/rails/railtie'
end
