require 'active_support/core_ext/string/output_safety'

module GoogleTagManager::Rails
  module ViewHelpers
    def gtm
      GoogleTagManager
    end

    def google_tag_manager
      ''.tap do |snippet|
        snippet.concat(GoogleTagManager.to_html) if GoogleTagManager.valid_gtm_id?
        GoogleTagManager.reset_data_layer!
      end.html_safe
    end

    def google_tag_manager_events
      prefix = GoogleTagManager.events_data_prefix
      prefix_size = prefix.length
      <<-GTM_EVENTS.html_safe
<script type="text/javascript">
/* <![CDATA[ */
(function($,document,window,undefined){
$(document).ready(function() {
  #{(GoogleTagManager.live_events? ? "$('body').on('click','[data-#{prefix}-event]'" : "$('[data-#{prefix}-event]').on('click'")}, function() {
    var push_hash = {};
    $.each($(this).data(), function(key, value){
      if(key.substring(0, #{prefix_size}) == '#{prefix}') {
        var gtm_key = key.substring(#{prefix_size}, #{prefix_size + 1}).toLowerCase() + key.substring(#{prefix_size + 1}); 
        push_hash[gtm_key] = value;
      };
    });
    #{%!console.log('[GoogleTagManager] dataLayer.push({');! if GoogleTagManager.debug_mode? }
    #{%!$.each(push_hash, function(k,v){ console.log("[GoogleTagManager]   '" + k + "': '" + v + "'")});! if GoogleTagManager.debug_mode? }
    #{%!console.log('[GoogleTagManager] });');! if GoogleTagManager.debug_mode? }
    dataLayer.push(push_hash);
  });
});
})(jQuery,document,window)
/* ]]> */
</script>
      GTM_EVENTS
    end
  end
end
