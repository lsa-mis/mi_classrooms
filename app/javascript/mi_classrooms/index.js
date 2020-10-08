  // Include external resources for this app_files
  // import 'bootstrap'

  // Include internal resources for this app
  import './javascripts/application'

  require.context("./stylesheets", true, /\.(css|scss|sass)$/)
  require.context('./images/', true, /.(gif|jpg|jpeg|png|svg)$/)
