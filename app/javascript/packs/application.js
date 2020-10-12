// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.

require("@rails/ujs").start()
require("@rails/activestorage").start()
require("channels")

var Turbolinks = require("turbolinks")
Turbolinks.start()

// Specific frontend applications
// import 'mi_classrooms'

import 'mi_classrooms/stylesheets/application.sass'
import 'mi_classrooms/stylesheets/_header.sass'
import 'mi_classrooms/stylesheets/_flash_errors.sass'
import 'mi_classrooms/stylesheets/_footer.sass'
import 'mi_classrooms/stylesheets/_feedback.sass'
import 'mi_classrooms/stylesheets/ribbons.sass'

import '@fortawesome/fontawesome-free/js/all';
require.context('../mi_classrooms/images/', true, /.(gif|jpg|jpeg|png|svg)$/)

// require('trix')
// require('@rails/actiontext')
// import 'trix/dist/trix.css'

import "controllers"