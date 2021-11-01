window.dataLayer = window.dataLayer || []
function gtag() { dataLayer.push(arguments) }

window.gtag('js', new Date())

const trackGoogleAnalytics = (event) => {
  window.gtag('config', 'UA-211737475-1', {
    'cookie_flags': 'max-age=7200;secure;samesite=none'
  })
}

document.addEventListener('turbolinks:load', trackGoogleAnalytics)


// TO BE CLEANED UP AFTER CONFIRMSTION THIS IS WORKING
// <!-- Global site tag (gtag.js) - Google Analytics -->
// <script async src="https://www.googletagmanager.com/gtag/js?id=UA-211737475-1"></script>
// <script>
//   window.dataLayer = window.dataLayer || [];
//   function gtag(){dataLayer.push(arguments);}
//   gtag('js', new Date());

//   gtag('config', 'UA-211737475-1');
// </script>