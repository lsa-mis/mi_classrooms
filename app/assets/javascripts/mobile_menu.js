// grab everything we need
var btn = document.querySelector('.mobile-menu-button');
var sidebar = document.querySelector('.sidebar');

// add our event between the click
btn.addEventListener('click', () => {
  sidebar.classList.toggle('-translate-x-full');
})