import { Controller } from 'stimulus'

export default class extends Controller {
  static targets = ['image1', 'image1text', 'image2']

  tobedeleted(event) {
    console.log("add image message")
    this.image1Target.remove()
    this.image1textTarget.innerHTML = "I am hungry"

    /* delete remove button
    add message to DOM element */
    // this.imageTarget.remove()
  }
}
