import { Controller } from "stimulus"
// import Rails from '@rails/ujs';

const noUiSlider = require("nouislider");

export default class extends Controller {
  static targets = ["slider", "reset", "minimum", "maximum"]

  initialize() {

    this.setup()
    // this.minimumTarget.classList.add('hidden')
  }

  setup() {

    const slider = this.sliderTarget;
    // const resetSlider = this.resetTarget;
    const minimumCapacity = parseInt(this.data.get("minimum"))
    const maximumCapacity = parseInt(this.data.get("maximum"))
    
    noUiSlider.create(slider, {
      range: {
        'min': 1,
        'max': 600
      },
      step: 5,
      // Handles start at ...
      start: [minimumCapacity , maximumCapacity],
      connect: true,
      direction: 'ltr',
      orientation: 'horizontal',
      behaviour: 'tap-drag',
      tooltips: true,
      format: {
        to: function (value) {
          return parseInt(value) + '';
        },
        from: function (value) {
          return value.replace(',-', '');
        },
      },
    });
  }

// END SETUP
updateSlider(){

  const myslider = this.sliderTarget
  const capacity = myslider.noUiSlider.get();

  this.minimumTarget.value = parseInt(capacity[0])
  this.maximumTarget.value = parseInt(capacity[1])

}

// data-action="mouseover->popover#mouseOver mouseout->popover#mouseOut"

}
