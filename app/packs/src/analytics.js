window.dataLayer = window.dataLayer || [];
function gtag() { dataLayer.push(arguments); }
gtag('js', new Date());

document.addEventListener("turbolinks:load", function(event) {
  gtag('config', 'UA-211737475-1', {
    page_location: event.data.url,
    page_path: event.srcElement.location.pathname,
    page_title: event.srcElement.title,
    'cookie_flags': 'max-age=7200;secure;samesite=none'
  });
})

export default gtag

// TO BE CLEANED UP AFTER CONFIRMSTION THIS IS WORKING
// <!-- Global site tag (gtag.js) - Google Analytics -->
// <script async src="https://www.googletagmanager.com/gtag/js?id=UA-211737475-1"></script>
// <script>
//   window.dataLayer = window.dataLayer || [];
//   function gtag(){dataLayer.push(arguments);}
//   gtag('js', new Date());

//   gtag('config', 'UA-211737475-1');
// </script>