window.dataLayer = window.dataLayer || []
function gtag() { dataLayer.push(arguments) }

window.gtag('js', new Date())

const trackGoogleAnalytics = (event) => {
  window.gtag('config', 'GA_MEASUREMENT_ID', {
    'cookie_flags': 'max-age=7200;secure;samesite=none'
  })
}

document.addEventListener('turbolinks:load', trackGoogleAnalytics)