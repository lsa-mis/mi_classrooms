# Pin npm packages by running ./bin/importmap

pin 'application'

# Core Rails packages
pin '@hotwired/turbo-rails', to: 'turbo.min.js'
pin '@hotwired/stimulus', to: 'stimulus.min.js'
pin 'stimulus', to: 'stimulus.min.js' # alias for old-style imports
pin '@rails/actiontext', to: 'actiontext.esm.js'
pin '@rails/activestorage', to: 'activestorage.esm.js'
pin '@rails/actioncable', to: 'actioncable.esm.js'
pin 'trix'

# Third-party Stimulus components (vendored in vendor/javascript/)
pin 'tailwindcss-stimulus-components', to: 'tailwindcss-stimulus-components.js'

# Third-party libraries
pin 'bigger-picture', to: 'bigger-picture.js' # vendored - lightweight lightbox
pin 'pannellum', to: 'pannellum.js' # vendored
pin 'pannellum-rooms', to: 'pannellum.js' # alias for pannellum

# Stimulus controllers (pin all from directory)
pin_all_from 'app/javascript/controllers', under: 'controllers'

# Channels
pin_all_from 'app/javascript/channels', under: 'channels'
