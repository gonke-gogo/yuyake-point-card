import { Controller } from "@hotwired/stimulus"

// Auto-dismisses the "stamp acquired" celebration banner shown after a
// successful checkin, so it doesn't linger on the mypage indefinitely.
export default class extends Controller {
  connect() {
    this.timeout = setTimeout(() => this.dismiss(), 3200)
  }

  disconnect() {
    clearTimeout(this.timeout)
  }

  dismiss() {
    this.element.classList.add("stamp-toast-fade-out")
    this.element.addEventListener("animationend", () => this.element.remove(), { once: true })
  }
}
