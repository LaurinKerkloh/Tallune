import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["frame"]

  select(event) {
    this.#unmark()
    event.currentTarget.setAttribute("aria-current", "true")
  }

  close() {
    this.#unmark()
    // A frame ignores a click that sets the src it already has, so reopening the same transaction needs it cleared.
    this.frameTarget.removeAttribute("src")
    this.frameTarget.replaceChildren()
  }

  // Clicking another transaction switches the details instead of closing them.
  closeOutside(event) {
    if (this.frameTarget.contains(event.target) || event.target.closest("[data-action~='transaction-details#select']")) return

    this.close()
  }

  #unmark() {
    this.element.querySelectorAll("[aria-current='true']").forEach((item) => item.removeAttribute("aria-current"))
  }
}
