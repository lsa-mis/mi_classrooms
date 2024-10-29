import { Controller } from "@hotwired/stimulus"
export default class extends Controller {
  static targets = ['form', 'sidebar', 'min_capacity', 'max_capacity', 'capacity_error']

  search() {
    clearTimeout(this.timeout)

    this.timeout = setTimeout(() => {
      this.formTarget.requestSubmit()
      this.sidebarTarget.classList.toggle('-translate-x-full')
    }, 200)
  }

  checkboxSubmit() {
    this.formTarget.requestSubmit()
    this.sidebarTarget.classList.toggle('-translate-x-full')
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
      }
      else {
        this.capacity_errorTarget.classList.add("capacity-error--hide")
        this.capacity_errorTarget.classList.remove("capacity-error--display")
        this.capacity_errorTarget.innerText = ""

        this.formTarget.requestSubmit()
        this.sidebarTarget.classList.toggle('-translate-x-full')
      }
    }, 200)
  }

  sortCapacity() {
    this.formTarget.requestSubmit()
  }

  clearFilters() {
    var url = window.location.pathname
    Turbo.visit(url)
  }
}
