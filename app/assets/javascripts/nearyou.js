
const nearyouBtn = document.getElementById('nearyou-btn');

if(nearyouBtn) {
  nearyouBtn.addEventListener('click', function(event) {
    event.preventDefault();
    if (!navigator.geolocation) {
      window.location.href = '/nearyou';
    }
    else {
      nearyouBtn.innerText = 'Loading...';
      navigator.geolocation.getCurrentPosition(function(position) {
        const latitude = position.coords.latitude;
        const longitude = position.coords.longitude;
        window.location.href = `/nearyou?latitude=${latitude}&longitude=${longitude}`;
      });
    }
  });
}
  