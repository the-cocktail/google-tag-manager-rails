require 'test_helper'

class GoogleTagManagerTest < ActiveSupport::TestCase
  test 'GoogleTagManager is a module' do
    assert_kind_of Module, GoogleTagManager
  end

  test '.to_html should return the gtm_id when defined' do
    assert GoogleTagManager.to_html =~ /'#{GoogleTagManager::PLACEHOLDER_GTM_ID}'/
    GoogleTagManager.gtm_id = gtm_id = 'GTM-1234567890'
    assert GoogleTagManager.to_html =~ /'#{gtm_id}'/
    assert (GoogleTagManager.to_html =~ /'#{GoogleTagManager::PLACEHOLDER_GTM_ID}'/).nil?
  end
end
