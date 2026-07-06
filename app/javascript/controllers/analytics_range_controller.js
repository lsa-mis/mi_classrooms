import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { url: String }

  change(event) {
    const range = encodeURIComponent(event.target.value)
    window.location.assign(`${this.urlValue}?range=${range}`)
  }
}
