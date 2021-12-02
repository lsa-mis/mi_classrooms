import { Controller } from 'stimulus'
export default class extends Controller {
  static targets = ['form', 'status', 'sidebar', 'min_capacity', 'max-capacity', 'capacity_error']

  search() {
    clearTimeout(this.timeout)

    this.timeout = setTimeout(() => {
      this.statusTarget.textContent = 'Updating...'
      Turbo.navigator.submitForm(this.formTarget)
      this.sidebarTarget.classList.toggle('-translate-x-full')
    }, 600)
  }

  checkboxSubmit() {
    clearTimeout(this.timeout)

    this.timeout = setTimeout(() => {
      this.statusTarget.textContent = 'Updating...'
      Turbo.navigator.submitForm(this.formTarget)
      this.sidebarTarget.classList.toggle('-translate-x-full')
    }, 0)
  }

  capacitySubmit() {
    var min_capacity = this.min_capacityTarget
    var max_capacity = this.max_capacityTarget

    if (min_capacity > max_capacity) {
      this.capacity_errorTarget.classList.add("device-error--display")
      this.capacity_errorTarget.classList.remove("device-error--hide")
    }
    else {
      this.capacity_errorTarget.classList.add("device-error--hide")
      this.capacity_errorTarget.classList.remove("device-error--display")
    }

    clearTimeout(this.timeout)

    this.timeout = setTimeout(() => {
      this.statusTarget.textContent = 'Updating...'
      Turbo.navigator.submitForm(this.formTarget)
      this.sidebarTarget.classList.toggle('-translate-x-full')
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
