Installation
=============

Add the following to your Gemfile:

``
  gem 'google-tag-manager-rails', github: 'the-cocktail/google-tag-manager-rails'
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

Per environment config
----

google-tag-manager-rails will only write out a tag if `GoogleTagManager.gtm_id` is set. If you don't set the value in your development, testing, or staging environments, no tags will be written.

If you'd like to add them, in config/environments/{development,staging}.rb :

```ruby
GoogleTagManager.gtm_id = "GTM-XXXX" # Where GTM-XXXX is your container ID from Google Tag Manager
```

Data Layer Variables
====

```ruby
GoogleTagManager.variable = '1'
GoogleTagManager.data_layer          # => {variable: "1"} (freezed copy)
GoogleTagManager.add_to_data_layer \
  other_variable: "5",
  yet_another_variable: "9"
GoogleTagManager.data_layer          # => {variable: "1", other_variable: "5", yet_another_variable: "9"} (freezed copy)
GoogleTagManager.variable  ||= '2'   # ignored, cause "variable" already has a value
GoogleTagManager.variable2 ||= '2'   # set, cause "variable2" hasn't been set
GoogleTagManager.data_layer          #=> {variable: "1", variable2: "2", other_variable: "5", yet_another_variable: "9"}
```

From the views you can access to the GoogleTagManager class using the ''gtm'' helper:

```ruby
gtm.variable = '1'
```

Events
======

In order to send events you need jQuery and call the following helper after its inclusion (a safe place would be before the closing body tag): 

```erb
<%= google_tag_manager_events %>
</body>
```

In addition you have to add the **data-gtm-event** attribute to the elements that should fire events when:

* **submitted** (on submit event) when used in **form** tags,
* **changed** (on change event) when used in **select** tags,
* **clicked** (on click event) when used in **any other** tag.

```html
<a href="/wadus" data-gtm-event="wadusClicked">Wadus</a>
```

Previous code will push **'event': 'wadusClicked'** when the link is clicked.

Event variables
---------------

If you want to send a dinamic data layer variable along with the event, add a data attribute with the "gtm-" prefix followed by the variable name. For example:

```html
<a href="/wadus" data-gtm-event="wadusClicked" data-gtm-wadus-variable="3">Wadus</a>
```

That will push **'wadusVariable': '3'** to the Data Layer along with the event (notice that variable names will be "lowerCamelized").

Pushing with custom JavaScript events
-------------------------------------

If within your JS code **you stop the event propagation** needed to push a GTM event, you can trigger a **custom JS event** that will be listened by google-tag-manager-rails as an alternative to the standard event.

There're three types of custom events:

* alternatives for the "click" event (set with .custom_click_events=),
* alternatives for the "change" event (set with .custom_change_events=),
* alternatives for the "submit" event (set with .custom_submit_events=).

For example, if you're managing a submit form with Ajax stoping the submit event propagation and you trigger the "ajax_form_submitted" event when the form is submitted, you should config google-tag-manager-rails like this:

```ruby
GoogleTagManager.custom_submit_events = 'ajax_form_submitted'
```

Event data attributes prefix
----------------------------

If you don't like data-**gtm** as prefix for your data attributes you can set another one. For example, if you configure it like this:

```ruby
GoogleTagManager.gtm_id = "GTM-XXXX"
GoogleTagManager.events_data_prefix = "google-tag-manager"
```

Then in your HTML you define an event like this:

```html
<a href="/wadus" data-google-tag-manager-event="wadusClicked">Wadus</a>
```

Debugging Events
----------------

If you add the following line in our config/environments/development.rb every dataLayer.push will be showed in the console:

```ruby
GoogleTagManager.debug_mode = true
```

"Live" Events
-------------

If you load dinamic contents with GTM events markup you will have to add this line to your config in order to have them pushed:

```ruby
GoogleTagManager.live_events = true
```
