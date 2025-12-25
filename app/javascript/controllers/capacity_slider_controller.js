import { Controller } from "@hotwired/stimulus"
import noUiSlider from "nouislider"

export default class extends Controller {
  static targets = ["slider", "reset", "minimum", "maximum"]

  initialize() {
    this.setup()
  }

  setup() {
    const slider = this.sliderTarget
    const minimumCapacity = parseInt(this.data.get("minimum"))
    const maximumCapacity = parseInt(this.data.get("maximum"))

    noUiSlider.create(slider, {
      range: {
        'min': 1,
        'max': 600
      },
      step: 5,
      start: [minimumCapacity, maximumCapacity],
      connect: true,
      direction: 'ltr',
      orientation: 'horizontal',
      behaviour: 'tap-drag',
      tooltips: true,
      format: {
        to: function (value) {
          return parseInt(value) + ''
        },
        from: function (value) {
          return value.replace(',-', '')
        },
      },
    })
  }

  updateSlider() {
    const myslider = this.sliderTarget
    const capacity = myslider.noUiSlider.get()

    this.minimumTarget.value = parseInt(capacity[0])
    this.maximumTarget.value = parseInt(capacity[1])
  }
}
