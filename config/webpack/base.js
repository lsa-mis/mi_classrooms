const path = require('path')
const { webpackConfig, merge } = require('@rails/webpacker')
const WebpackAssetsManifest = require('webpack-assets-manifest')

const manifestPlugin =
  webpackConfig.plugins.find(r => r instanceof WebpackAssetsManifest)
  if (manifestPlugin) {
    manifestPlugin.options.contextRelativeKeys = true;
    // if asset path begins e.g. with `images/` it will be replaced with `media/images/`
    const assetPrefixes = ['images/', 'fonts/', 'pdfs/'];
    manifestPlugin.options.customize = function(entry) {
      const assetPrefix = assetPrefixes.find(prefix => entry.key.startsWith(prefix));
      if (assetPrefix) {
        return {
          key: entry.key.replace(assetPrefix, `media/${assetPrefix}`),
          value: entry.value
        };
      }

      return entry;
    };
}

const customConfig = {
  context: path.resolve(__dirname, '../../app/packs/images'), // Default webpacker setup, old setup was app/javascripts, this is the value from webpacker.yml "source_path"
  // ...rest of your customConfig goes here
}

module.exports = merge(webpackConfig, customConfig)