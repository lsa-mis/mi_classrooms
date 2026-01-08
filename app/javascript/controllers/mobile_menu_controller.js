import { Controller } from "@hotwired/stimulus"

// Replaces app/assets/javascripts/mobile_menu.js
// Toggles sidebar visibility on mobile devices
export default class extends Controller {
  static targets = ["sidebar"]

  toggle() {
    this.sidebarTarget.classList.toggle("-translate-x-full")
  }
}
