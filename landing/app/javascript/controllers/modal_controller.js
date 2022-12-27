import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["modal", "backdrop"]

  open() {
    this.modalTarget.classList.remove("hidden")
    this.backdropTarget.classList.remove("hidden")
  }

  close() {
    this.modalTarget.classList.add("hidden")
    this.backdropTarget.classList.add("hidden")
  }
}