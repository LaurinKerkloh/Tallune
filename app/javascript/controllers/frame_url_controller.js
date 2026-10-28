import { Controller } from "@hotwired/stimulus"

// Turbo can only advance to the frame's own URL, so the page copies the filters of each load into its URL instead.
// That keeps a reload on this page, and the params it doesn't sync, like an account picked in the URL, stay put.
export default class extends Controller {
  static values = { params: Array }

  sync({ target }) {
    const loaded = new URL(target.src, location.href).searchParams
    const url = new URL(location.href)

    for (const name of this.paramsValue) {
      url.searchParams.delete(name)
      if (loaded.has(name)) url.searchParams.set(name, loaded.get(name))
    }
    history.replaceState(history.state, "", url)
  }
}
