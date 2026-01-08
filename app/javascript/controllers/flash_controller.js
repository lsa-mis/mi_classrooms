import { Controller } from "@hotwired/stimulus"

// Replaces app/assets/javascripts/flash_timeout.js
// Automatically removes flash messages after a timeout
export default class extends Controller {
  static values = {
    timeout: { type: Number, default: 3000 }
  }

  connect() {
    this.timeout = setTimeout(() => {
      this.dismiss()
    }, this.timeoutValue)
  }

  disconnect() {
    if (this.timeout) {
      clearTimeout(this.timeout)
    }
  }

  dismiss() {
    this.element.remove()
  }
}
