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

    // Find all anchor links with images inside the controller element
    const anchors = this.element.querySelectorAll('a[href]')

    // Convert anchors to items array for bigger-picture
    this.items = Array.from(anchors).map(anchor => {
      const img = anchor.querySelector('img')
      return {
        img: anchor.href,
        thumb: img ? img.src : anchor.href,
        alt: img ? img.alt : '',
        width: 1920,
        height: 1080
      }
    })

    // Add click handlers to each anchor
    anchors.forEach((anchor, index) => {
      anchor.addEventListener('click', (e) => {
        e.preventDefault()
        this.open(index)
      })
    })
  }

  open(position = 0) {
    this.bp.open({
      items: this.items,
      position: position,
      scale: this.optionsValue.scale || 0.99,
      ...this.optionsValue
    })
  }

  disconnect() {
    if (this.bp) {
      this.bp.close()
    }
  }
}
