import { Controller } from "@hotwired/stimulus"
import "pannellum"

export default class extends Controller {
  connect() {
    const panoImage = this.data.get("panoimage")
    const panoPreview = this.data.get("panopreview")
    this.initPanorama(panoImage, panoPreview)
  }

  initPanorama(panoImage, panoPreview) {
    this.viewer = window.pannellum.viewer('panorama', {
      type: "equirectangular",
      panorama: panoImage,
      preview: panoPreview,
      autoLoad: false
    })

    // Wait for DOM to be ready, then setup accessibility
    requestAnimationFrame(() => {
      this.setupLoadButtonAccessibility()
    })
  }

  setupLoadButtonAccessibility() {
    const container = this.viewer.getContainer()
    const loadButton = container.querySelector('.pnlm-load-button')

    if (loadButton) {
      // Make the load button focusable and accessible
      loadButton.setAttribute('tabindex', '0')
      loadButton.setAttribute('role', 'button')
      loadButton.setAttribute('aria-label', 'Press Enter to load 360-degree panorama')

      // Handle keyboard activation (Enter or Space)
      loadButton.addEventListener('keydown', (event) => {
        if (event.key === 'Enter' || event.key === ' ') {
          event.preventDefault()
          loadButton.click()
        }
      })
    }

    // After panorama loads, ensure container is focusable for arrow key navigation
    this.viewer.on('load', () => {
      container.setAttribute('tabindex', '0')
      container.focus()
    })
  }
}
