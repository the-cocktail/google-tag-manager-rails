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
      GoogleTagManager.valid_gtm_id? ? GoogleTagManager.events_to_html.html_safe : ''
    end
  end
end
