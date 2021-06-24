  process.env.NODE_ENV = process.env.NODE_ENV || 'staging'

  const environment = require('./base')

  module.exports = environment.toWebpackConfig()

