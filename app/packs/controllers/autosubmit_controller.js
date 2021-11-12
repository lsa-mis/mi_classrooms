import { Controller } from 'stimulus'
export default class extends Controller {
  static targets = ['form', 'status']

  search() {
    clearTimeout(this.timeout)

    this.timeout = setTimeout(() => {
      this.statusTarget.textContent = 'Updating...'
      Turbo.navigator.submitForm(this.formTarget)
    }, 600)
  }

  checkboxSubmit() {
    clearTimeout(this.timeout)

    this.timeout = setTimeout(() => {
      this.statusTarget.textContent = 'Updating...'
      Turbo.navigator.submitForm(this.formTarget)
    }, 0)
  }

  change(event) {
    event.preventDefault()
    Turbo.navigator.submitForm(this.formTarget)
  }

  clearFilters() {
    this.formTarget.reset()
    Turbo.navigator.submitForm(this.formTarget)
  }
}
