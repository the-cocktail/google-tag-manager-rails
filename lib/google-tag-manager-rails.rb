module GoogleTagManager
  PLACEHOLDER_GTM_ID = "GTM-XXXX"
  PLACEHOLDER_GTM_EVENTS_DATA_PREFIX = "gtm"

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

    def debug_mode=(value)
      @@debug_mode = value
    end

    def debug_mode?
      @@debug_mode ||= false
    end

    def live_events= value
      @@live_events = value
    end

    def live_events?
      @@live_events ||= false
    end

    def events_data_prefix
      @@events_data_prefix ||= PLACEHOLDER_GTM_EVENTS_DATA_PREFIX
    end

    def events_data_prefix=(prefix)
      @@events_data_prefix = prefix
    end

    def custom_click_events=(value)
      @@custom_click_events ||= value
    end

    def custom_click_events
      @@custom_click_events ||= ''
    end

    def custom_submit_events=(value)
      @@custom_submit_events ||= value
    end

    def custom_submit_events
      @@custom_submit_events ||= ''
    end

    def custom_change_events=(value)
      @@custom_change_events ||= value
    end

    def custom_change_events
      @@custom_change_events ||= ''
    end

    def to_html
      "<!-- Google Tag Manager -->\n" +
      data_layer_tag + "\n" +
      container_tag + "\n" +
      "<!-- End Google Tag Manager -->"
    end

    def events_to_html
      prefix_size = events_data_prefix.length
      <<-GTM_EVENTS.html_safe
<script type="text/javascript">
/* <![CDATA[ */
(function($,document,window,undefined){

  var GoogleTagManagerRails = {
    bind_events: function() {
      $(#{clicks_bind_statement} GoogleTagManagerRails.push_event_for_tag);
      $(#{submits_bind_statement} GoogleTagManagerRails.push_event_for_tag);
      $(#{changes_bind_statement} GoogleTagManagerRails.push_event_for_tag);
    },

    push_event_for_tag: function() {
      var push_hash = GoogleTagManagerRails.tag_push_hash(this);
      #{log_push_variables if debug_mode?}
      dataLayer.push(push_hash);
    },
    tag_push_hash: function(tag) {
      var push_hash = {};
      $.each($(tag).data(), function(key, value){
        if(key.substring(0, #{prefix_size}) == '#{events_data_prefix}') {
          var gtm_key = key.substring(#{prefix_size}, #{prefix_size + 1}).toLowerCase() + key.substring(#{prefix_size + 1});
          push_hash[gtm_key] = value;
        };
      });
      return(push_hash);
    }
  };

  $(document).ready(GoogleTagManagerRails.bind_events);

  })(jQuery,document,window)
/* ]]> */
</script>
      GTM_EVENTS
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
      end
    end

    def data_layer
      data_layer_hash.dup.freeze
    end

    def add_to_data_layer hash, overwrite = true, &block
      raise 'GoogleTagManager error: hash required in order to add variables to the Data Layer' unless hash.is_a?(Hash)
      if overwrite
        data_layer_hash.merge! hash, &block
      else
        @@data_layer_hash = data_layer_hash.deep_merge hash do |key, old_value, new_value|
          # on non-overwrite mode, if we are given a block, then we use it
          if block_given?
            block.call(key, old_value, new_value)
          else
            # If we are not given a block and both values are arrays we concat them
            if old_value.is_a?(Array)  && new_value.is_a?(Array)
              (old_value + new_value).uniq
            # If they are not arrays we return the new one
            else
              new_value
            end
          end
        end
      end

    end

    def reset_data_layer!
      @@data_layer_hash = {} if @@data_layer_hash
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
          "{\n  #{data.map do |key, value|
              "'#{key}': #{serialize(value)}"
            end.join(",\n  ")
            }\n}"
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
<noscript><iframe src="//www.googletagmanager.com/ns.html?id=#{gtm_id}" height="0" width="0" style="display:none;visibility:hidden"></iframe></noscript>
<script>(function(w,d,s,l,i){w[l]=w[l]||[];w[l].push({'gtm.start': new Date().getTime(),event:'gtm.js'});var f=d.getElementsByTagName(s)[0], j=d.createElement(s),dl=l!='dataLayer'?'&l='+l:'';j.async=true;j.src='//www.googletagmanager.com/gtm.js?id='+i+dl;f.parentNode.insertBefore(j,f);})(window,document,'script','dataLayer','#{gtm_id}');</script>
        HTML
      end

      def elements_selector(options={})
        prefix = options[:prefix] || ''
        suffix = options[:suffix] || ''
        "#{prefix}[data-#{events_data_prefix}-event]#{suffix}"
      end

      def clicks_bind_statement
        bind_statement :click, elements_selector(suffix: ':not(form, select)')
      end

      def submits_bind_statement
        bind_statement :submit, elements_selector(prefix: 'form')
      end

      def changes_bind_statement
        bind_statement :change, elements_selector(prefix: 'select')
      end

      def events_for(event_type)
        "#{event_type} #{send("custom_#{event_type}_events")}".strip
      end

      def bind_statement(event_type, selector)
        if live_events?
          "'body').on('#{events_for(event_type)}','#{selector}',"
        else
          "'#{selector}').on('#{events_for(event_type)}',"
        end
      end

      def log_push_variables
        <<-LOG_PUSH_VARIABLES
        window.console && console.log('[GoogleTagManager] dataLayer.push({');
        $.each(push_hash, function(k,v){ window.console && console.log("[GoogleTagManager]   '" + k + "': '" + v + "'")});
        window.console && console.log('[GoogleTagManager] });');
        LOG_PUSH_VARIABLES
      end
  end

end
if defined?(Rails)
  require 'google-tag-manager/rails/railtie'
end
