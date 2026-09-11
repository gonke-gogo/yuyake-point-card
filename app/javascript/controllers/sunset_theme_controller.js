import { Controller } from "@hotwired/stimulus"

// Drives the mypage background gradient from today's actual sunset time.
// Recomputed on an interval (not a continuous animation) to keep this cheap
// on battery; the CSS `transition` on .sunset-panel smooths the jumps.
const PHASES = [
  { name: "day", from: "#fff7ed", via: "#fffbeb", to: "#ffffff" },
  { name: "golden-hour", from: "#fed7aa", via: "#fdba74", to: "#fff7ed" },
  { name: "sunset", from: "#fb923c", via: "#f472b6", to: "#fed7aa" },
  { name: "dusk", from: "#312e81", via: "#7c3aed", to: "#fb923c" },
  { name: "night", from: "#0f172a", via: "#1e293b", to: "#312e81" },
]

const GOLDEN_HOUR_MS = 60 * 60 * 1000
const UPDATE_INTERVAL_MS = 60 * 1000

export default class extends Controller {
  static values = {
    sunsetAt: String,
    duskAt: String,
  }

  connect() {
    this.update()
    this.timer = setInterval(() => this.update(), UPDATE_INTERVAL_MS)
  }

  disconnect() {
    clearInterval(this.timer)
  }

  update() {
    const phase = this.currentPhase()
    this.element.style.setProperty("--sky-from", phase.from)
    this.element.style.setProperty("--sky-via", phase.via)
    this.element.style.setProperty("--sky-to", phase.to)
  }

  currentPhase() {
    const now = Date.now()
    const sunsetAt = new Date(this.sunsetAtValue).getTime()
    const duskAt = new Date(this.duskAtValue).getTime()

    if (now < sunsetAt - GOLDEN_HOUR_MS) return PHASES[0]
    if (now < sunsetAt) return PHASES[1]
    if (now < duskAt) return PHASES[2]
    if (now < duskAt + GOLDEN_HOUR_MS) return PHASES[3]
    return PHASES[4]
  }
}
