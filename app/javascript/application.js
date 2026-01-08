// Entry point for importmap-rails

// Trix and ActionText
import "trix"
import "@rails/actiontext"

// Turbo
import "@hotwired/turbo-rails"

// ActionCable channels
import "channels"

// Active Storage
import * as ActiveStorage from "@rails/activestorage"
ActiveStorage.start()

// Stimulus controllers
import "controllers"
