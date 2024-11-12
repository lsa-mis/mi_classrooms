import { Controller } from "@hotwired/stimulus"
export default class extends Controller {
  static targets = ["panorama"]

  connect() {
    console.log("Pannellum controller connected")
  }

}




