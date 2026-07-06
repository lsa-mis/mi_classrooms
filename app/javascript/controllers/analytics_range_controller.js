import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  change(event) {
    const url = new URL(window.location.href)
    url.searchParams.set("range", event.target.value)
    window.location.assign(url.toString())
  }
}
