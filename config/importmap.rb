# Pin npm packages by running ./bin/importmap

pin 'application'
pin 'tailwindcss-stimulus-components' # @6.1.2
pin '@hotwired/stimulus', to: '@hotwired--stimulus.js' # @3.2.2

pin '@stimulus-components/lightbox', to: '@stimulus-components--lightbox.js' # @4.0.0
pin 'lightgallery' # @2.7.2
pin '@hotwired/stimulus-loading', to: 'stimulus-loading.js', preload: true
pin '@hotwired/turbo-rails', to: 'turbo.min.js'
pin 'flatpickr' # @4.6.13
pin 'stimulus-flatpickr' # @3.0.0
pin_all_from 'app/javascript/controllers', under: 'controllers'
pin 'trix', to: 'https://ga.jspm.io/npm:trix@2.0.4/dist/trix.esm.min.js'
pin '@rails/actiontext', to: 'actiontext.js'
pin '@rails/actioncable', to: 'actioncable.esm.js'
pin '@rails/activestorage', to: 'activestorage.esm.js'
# ... other pins ...
pin 'pannellum-css', to: 'https://cdn.jsdelivr.net/npm/pannellum-react@1.3.6/es/pannellum/css/pannellum.css'
# or if you have a local copy
pin 'pannellum-css', to: 'pannellum.css'
