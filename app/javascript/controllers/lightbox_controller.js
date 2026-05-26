import { Controller } from "@hotwired/stimulus"
import BiggerPicture from "bigger-picture"

export default class extends Controller {
  static values = {
    options: { type: Object, default: {} }
  }

  connect() {
    this.bp = BiggerPicture({
      target: document.body
    })

    this.anchors = this.element.querySelectorAll('a[href]')
    this.boundOpen = this.openFromEvent.bind(this)

    this.anchors.forEach((anchor) => {
      anchor.addEventListener('click', this.boundOpen)
    })
  }

  openFromEvent(event) {
    event.preventDefault()

    // BiggerPicture reads each anchor's data-width/data-height to preserve aspect ratio.
    this.bp.open({
      items: this.anchors,
      el: event.currentTarget,
      scale: this.optionsValue.scale || 0.99,
      ...this.optionsValue
    })
  }

  disconnect() {
    if (this.anchors && this.boundOpen) {
      this.anchors.forEach((anchor) => {
        anchor.removeEventListener('click', this.boundOpen)
      })
    }

    if (this.bp) {
      this.bp.close()
    }
  }
}
