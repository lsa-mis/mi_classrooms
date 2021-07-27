// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.

import "@hotwired/turbo-rails"
import "channels"

import * as ActiveStorage from "@rails/activestorage"

import "../stylesheets/application.sass"
import '../stylesheets/_header.sass'
import '../stylesheets/_flash_errors.sass'
import '../stylesheets/_footer.sass'
import '../stylesheets/_feedback.sass'
import '../stylesheets/ribbons.sass'
import '../stylesheets/search.sass'

function importAll(r) {
  r.keys().forEach(r);
}
// Add relevant file extensions as needed below.
importAll(require.context('../images/', true, /\.(svg|jpg|gif|png)$/));

// require('trix')
// require('@rails/actiontext')
// import 'trix/dist/trix.css'

import "controllers"

ActiveStorage.start()