import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["info_text_area", "info_text_short_area"]

  toggle() {
    this.info_text_areaTarget.classList.add("infopanel--display")
    this.info_text_areaTarget.classList.remove("infopanel--hide")
    this.info_text_short_areaTarget.classList.add("infopanel--hide")
    this.info_text_short_areaTarget.classList.remove("infopanel--display")
  }

  toggle2() {
    this.info_text_areaTarget.classList.add("infopanel--hide")
    this.info_text_areaTarget.classList.remove("infopanel--display")
    this.info_text_short_areaTarget.classList.add("infopanel--display")
    this.info_text_short_areaTarget.classList.remove("infopanel--hide")
  }
}
