# Pin npm packages by running ./bin/importmap

pin "application"

# Core Rails packages
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "stimulus", to: "stimulus.min.js" # alias for old-style imports
pin "@rails/actiontext", to: "actiontext.esm.js"
pin "@rails/activestorage", to: "activestorage.esm.js"
pin "@rails/actioncable", to: "actioncable.esm.js"
pin "trix"

# Third-party Stimulus components
pin "tailwindcss-stimulus-components", to: "https://ga.jspm.io/npm:tailwindcss-stimulus-components@6.1.2/dist/tailwindcss-stimulus-components.module.js"

# Third-party libraries
pin "bigger-picture", to: "https://ga.jspm.io/npm:bigger-picture@1.1.17/dist/bigger-picture.mjs"
pin "pannellum", to: "pannellum.js" # vendored
pin "chart.js" # @4.5.1 — self-contained ESM bundle (esbuild from chart.js/auto, no external imports)

# Stimulus controllers (pin all from directory)
pin_all_from "app/javascript/controllers", under: "controllers"

# Channels
pin_all_from "app/javascript/channels", under: "channels"
# @kurkle/color is inlined in the chart.js bundle above — no separate pin needed
