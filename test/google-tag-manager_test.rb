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

  test '.valid_gtm_id? should be false if gtm_id does not start with "GTM-"' do
    GoogleTagManager.gtm_id = '1234567890'
    refute GoogleTagManager.valid_gtm_id?
    GoogleTagManager.gtm_id = 'GTM-1234567890'
    assert GoogleTagManager.valid_gtm_id?
  end

  test '.whatever=what should set a DataLayer variable called "whatever" with the value "what"' do
    GoogleTagManager.my_data_layer_variable = value = %$Hi, I'm the value! :)$
    assert GoogleTagManager.my_data_layer_variable == value
    assert GoogleTagManager.to_html =~ /'my_data_layer_variable'/
    assert GoogleTagManager.to_html =~ /Hi, I\\'m the value! :\)/
  end

  test '.data_layer should return a hash representing the current data layer' do
    assert GoogleTagManager.data_layer.is_a?(Hash)
  end

  test '.add_to_data_layer should add variables to the current data layer without removing the existing ones' do
    GoogleTagManager.first_data_layer_variable = 'first'
    GoogleTagManager.add_to_data_layer \
      second_data_layer_variable: 'second',
      third_data_layer_variable: 'third'
    assert GoogleTagManager.data_layer.keys.include? :first_data_layer_variable
    assert GoogleTagManager.data_layer.keys.include? :second_data_layer_variable
    assert GoogleTagManager.data_layer.keys.include? :third_data_layer_variable
  end
end
