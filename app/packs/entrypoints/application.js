// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.

require("trix")
require("@rails/actiontext")

import "@hotwired/turbo-rails"
require("@rails/ujs").start()
import "channels"

import * as ActiveStorage from "@rails/activestorage"

// import "../stylesheets/application.sass"
import 'lightgallery/css/lightgallery.css'

import gtag from '../src/analytics'
import 'trix/dist/trix.css'
import 'pannellum-rooms/pannellum.css'
function importAll(r) {
  r.keys().forEach(r);
}
// Add relevant file extensions as needed below.
// importAll(require.context('../images/', true, /\.(svg|jpg|gif|png)$/));

// import "controllers"

ActiveStorage.start()