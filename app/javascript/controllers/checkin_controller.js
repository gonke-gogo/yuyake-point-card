import { Controller } from "@hotwired/stimulus"

// Requests the visitor's current location and submits it along with the
// check-in. If location can't be obtained (denied, unsupported, timed out),
// we don't submit at all -- we show an in-place message directing the
// visitor to retry or ask venue staff for a manual check-in instead.
export default class extends Controller {
  static targets = ["loading", "error"]
  static values = {
    checkinUrl: String,
  }

  connect() {
    this.requestLocation()
  }

  retry() {
    this.errorTarget.classList.add("hidden")
    this.loadingTarget.classList.remove("hidden")
    this.requestLocation()
  }

  requestLocation() {
    if (!navigator.geolocation) {
      this.showError()
      return
    }

    navigator.geolocation.getCurrentPosition(
      (position) => this.submit(position.coords.latitude, position.coords.longitude),
      () => this.showError(),
      { enableHighAccuracy: true, timeout: 10000, maximumAge: 0 },
    )
  }

  submit(lat, lng) {
    const form = document.createElement("form")
    form.method = "POST"
    form.action = this.checkinUrlValue
    form.hidden = true

    form.append(this.hiddenInput("authenticity_token", this.csrfToken))
    form.append(this.hiddenInput("lat", lat))
    form.append(this.hiddenInput("lng", lng))

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

  showError() {
    this.loadingTarget.classList.add("hidden")
    this.errorTarget.classList.remove("hidden")
  }
}
