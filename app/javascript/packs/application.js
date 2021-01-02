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
require('mi_classrooms/stylesheets/application.sass')
require('mi_classrooms/stylesheets/_header.sass')
require('mi_classrooms/stylesheets/_flash_errors.sass')
require('mi_classrooms/stylesheets/_footer.sass')
require('mi_classrooms/stylesheets/_feedback.sass')
require('mi_classrooms/stylesheets/ribbons.sass')

require.context('mi_classrooms/images/', true, /.(gif|jpg|jpeg|png|svg)$/)

// require('trix')
// require('@rails/actiontext')
// import 'trix/dist/trix.css'

import "controllers"