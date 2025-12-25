# frozen_string_literal: true

# Pagy initializer file (Pagy 6.x)
# Customize only what you really need and notice that Pagy works also without any of the following lines.

# Pagy Variables
# See https://ddnexus.github.io/pagy/docs/api/pagy#variables

# Instance variables
Pagy::DEFAULT[:items] = 30

# Other Variables
Pagy::DEFAULT[:size] = [1, 2, 2, 1]

# Frontend Extras
require "pagy/extras/navs"

# Items extra: Allow the client to request a custom number of items per page
require "pagy/extras/items"
Pagy::DEFAULT[:items_param] = :items
Pagy::DEFAULT[:max_items] = 100

# Rails: extras assets path required by the helpers that use javascript
Rails.application.config.assets.paths << Pagy.root.join("javascripts")
