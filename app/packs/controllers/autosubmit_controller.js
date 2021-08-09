import { Controller } from 'stimulus'
export default class extends Controller {
  static targets = ['form', 'status']
	static values = { duration: String }

  connect() {
    this.timeout = null
    this.duration = fetch(this.durationValue) || 400

  }

	
  save() {
    clearTimeout(this.timeout)
		
    this.timeout = setTimeout(() => {
      this.statusTarget.textContent = 'Updating...'
      // this.formTarget.submit()
			this.element.requestSubmit()
    }, this.duration)
  }

  change(event){
    event.preventDefault()
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
