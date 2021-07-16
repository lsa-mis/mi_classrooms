import { Controller } from 'stimulus'
export default class extends Controller {
  static targets = ['form', 'status']

  connect() {
    this.timeout = null
    this.duration = this.data.get('duration') || 200
  }

  save() {
    clearTimeout(this.timeout)

    this.timeout = setTimeout(() => {
      this.statusTarget.textContent = 'Updating...'
      this.formTarget.submit()
    }, this.duration)
  }

  change(event){
    event.preventDefault()
    this.save()

  }
  checkboxSubmit() {
    preventDefault()
    this.save()
  }
  success() {
    this.timeout = setTimeout(() => {
      this.statusTarget.textContent = 'Updated'
    }, this.duration)

  }

  error() {
    this.setStatus('Unable to update!')
  }

  setStatus(message) {
    this.statusTarget.textContent = message

    this.timeout = setTimeout(() => {
      this.statusTarget.textContent = ''
    }, 2000)
  }
}
