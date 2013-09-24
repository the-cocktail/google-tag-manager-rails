require 'active_support/core_ext/string/output_safety'

module GoogleTagManager::Rails
  module ViewHelpers
    def google_tag_manager
      ''.tap do |snippet|
        snippet = GoogleTagManager.to_html.html_safe if GoogleTagManager.valid_gtm_id?
        GoogleTagManager.reset_data_layer!
      end
    end

    def gtm
      GoogleTagManager
    end
  end
end
