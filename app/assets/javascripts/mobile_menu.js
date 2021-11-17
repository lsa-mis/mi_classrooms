// grab everything we need
const btn = document.querySelector('.mobile-menu-button');
const sidebar = document.querySelector('.sidebar');

// add our event between the click
btn.addEventListener('click', () => {
  sidebar.classList.toggle('-translate-x-full');
})