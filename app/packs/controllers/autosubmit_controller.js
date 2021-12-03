import { Controller } from 'stimulus'
export default class extends Controller {
  static targets = ['form', 'status', 'sidebar', 'min_capacity', 'max_capacity', 'capacity_error']

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

  capacitySubmit(event) {
    clearTimeout(this.timeout)

    this.timeout = setTimeout(() => {
      var min_capacity = parseInt(this.min_capacityTarget.value)
      var max_capacity = parseInt(this.max_capacityTarget.value)

      if (min_capacity > max_capacity) {
        this.capacity_errorTarget.classList.add("capacity-error--display")
        this.capacity_errorTarget.classList.remove("capacity-error--hide")
        this.capacity_errorTarget.innerText = "Min should be smaller than Max"
        event.preventDefault()
      }
      else {
        this.capacity_errorTarget.classList.add("capacity-error--hide")
        this.capacity_errorTarget.classList.remove("capacity-error--display")
        this.capacity_errorTarget.innerText = ""

        this.statusTarget.textContent = 'Updating...'
        Turbo.navigator.submitForm(this.formTarget)
        this.sidebarTarget.classList.toggle('-translate-x-full')
      }
    }, 600)
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
