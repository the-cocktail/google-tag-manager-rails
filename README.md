Installation
=============

Add the following to your Gemfile:

``
  gem 'google-tag-manager-rails'
``

Then run:

``
  bundle install
``

Example Configuration
====

In config/environments/production.rb :

```ruby
GoogleTagManager.gtm_id = "GTM-XXXX" # Where GTM-XXXX is your container ID from Google Tag Manager
```

In app/views/layouts/application.html.erb:

```erb
<body>
  <%= google_tag_manager %>
  ...
```

Outputs both the standard container and the Data Layer.

Data Layer Variables
====

```ruby
GoogleTagManager.variable = "1"
GoogleTagManager.data_layer # => {variable: "1"} (freezed copy)
GoogleTagManager.add_to_data_layer other_variable: "2", yet_another_variable: "3"
GoogleTagManager.data_layer # => {variable: "1", other_variable: "2", yet_another_variable: "3"} (freezed copy)
```

From the views you can access to the GoogleTagManager class using the ''gtm'' helper:

```ruby
gtm.variable = '1'
```

Per environment config
----

google-tag-manager-rails will only write out a tag if `GoogleTagManager.gtm_id` is set. If you don't set the value in your development, testing, or staging environments, no tags will be written.

If you'd like to add them, in config/environments/{development,staging}.rb :

```ruby
GoogleTagManager.gtm_id = "GTM-XXXX" # Where GTM-XXXX is your container ID from Google Tag Manager
```


