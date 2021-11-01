import { Controller } from 'stimulus'
export default class extends Controller {
  static targets = ['form', 'status']

  search() {
    clearTimeout(this.timeout)
    console.log("search")

    this.timeout = setTimeout(() => {
      // this.statusTarget.textContent = 'Updating...'
      Turbo.navigator.submitForm(this.formTarget)
    }, 600)
  }

  checkboxSubmit() {
    console.log("checkbox")

    clearTimeout(this.timeout)

    this.timeout = setTimeout(() => {
      // this.statusTarget.textContent = 'Updating...'
      Turbo.navigator.submitForm(this.formTarget)
    }, 0)
  }

  change(event) {
    event.preventDefault()
    Turbo.navigator.submitForm(this.formTarget)
  }

  clearFilters() {
    console.log("clear")
    console.log(this.element)
    Turbo.navigator.this.formTarget.reset()
    Turbo.navigator.this.element.reset()

  }
}
