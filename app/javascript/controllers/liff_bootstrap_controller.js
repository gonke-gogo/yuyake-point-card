import { Controller } from "@hotwired/stimulus"

// Bootstraps the visitor's Rails session from LIFF: liff.init -> getIDToken
// -> POST /liff/session. Errors are shown in place on this page; once the
// session is established, Rails takes over via a normal redirect.
export default class extends Controller {
  static targets = ["loading", "error", "errorDetail"]
  static values = {
    liffId: String,
    returnTo: String,
    sessionUrl: String,
  }

  connect() {
    this.boot()
  }

  async boot() {
    try {
      if (!this.liffIdValue) throw new Error("Missing LIFF ID")

      await liff.init({ liffId: this.liffIdValue })

      if (!liff.isLoggedIn()) {
        liff.login()
        return
      }

      const idToken = liff.getIDToken()
      if (!idToken) throw new Error("Missing ID token")

      this.submit(idToken)
    } catch (error) {
      console.error("LIFF boot failed", error)
      this.showError(error)
    }
  }

  submit(idToken) {
    const form = document.createElement("form")
    form.method = "POST"
    form.action = this.sessionUrlValue
    form.hidden = true

    form.append(this.hiddenInput("authenticity_token", this.csrfToken))
    form.append(this.hiddenInput("id_token", idToken))
    if (this.hasReturnToValue && this.returnToValue) {
      form.append(this.hiddenInput("return_to", this.returnToValue))
    }

    document.body.append(form)
    // requestSubmit (not submit()) so Turbo Drive intercepts this like any
    // other form submission instead of forcing a full page reload.
    form.requestSubmit()
  }

  hiddenInput(name, value) {
    const input = document.createElement("input")
    input.type = "hidden"
    input.name = name
    input.value = value
    return input
  }

  get csrfToken() {
    return document.querySelector('meta[name="csrf-token"]')?.content
  }

  showError(error) {
    this.loadingTarget.classList.add("hidden")
    this.errorTarget.classList.remove("hidden")

    // TODO: remove this on-page detail once real-device LIFF testing is done.
    if (error && this.hasErrorDetailTarget) {
      const code = error.code ? `${error.code}: ` : ""
      this.errorDetailTarget.textContent = `${code}${error.message || error}`
      this.errorDetailTarget.classList.remove("hidden")
    }
  }
}
