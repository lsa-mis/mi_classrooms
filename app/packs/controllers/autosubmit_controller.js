import { Controller } from 'stimulus'
export default class extends Controller {
  static targets = ['form', 'status']

  search() {
    clearTimeout(this.timeout)

    this.timeout = setTimeout(() => {
      this.statusTarget.textContent = 'Updating...'
      this.element.requestSubmit()
    }, 600)
  }

}
