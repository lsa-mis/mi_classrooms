import { Controller } from "stimulus"

export default class extends Controller {
  static targets = [ "dropdown",  "mainnav"]

  mainnavtoggle() {
    event.preventDefault()
    this.mainnavTargets.forEach((el, i) => {
      el.classList.toggle("hidden")

    })
  }

  dropdowntoggle() {
    const { clientWidth } = this.element
    event.preventDefault()
    if (clientWidth > 640 ){
      this.dropdownTargets.forEach((el, i) => {
        el.classList.toggle("hidden")
      })
    }
  }
  hideuseractions(){
    const width = window.innerWidth
        || document.documentElement.clientWidth
        || document.body.clientWidth;
    if (width < 640 ){
      this.dropdownTargets.forEach((el, i) => {
        el.classList.add("hidden")
      })
    }
  }
}
