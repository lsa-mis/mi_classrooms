import { Controller } from 'stimulus'
export default class extends Controller {
  static targets = ['form']

  visible() {
    Turbo.navigator.submitForm(this.formTarget)
  }
}
