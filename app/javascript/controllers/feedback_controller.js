import { Controller } from "@hotwired/stimulus"

// Replaces app/assets/javascripts/feedback.js
// Integrates with Jira Issue Collector for feedback
export default class extends Controller {
  static values = {
    component: { type: String, default: "15319" }
  }

  connect() {
    // Set up the ATL_JQ_PAGE_PROPS for Jira Issue Collector
    window.ATL_JQ_PAGE_PROPS = {
      triggerFunction: (showCollectorDialog) => {
        this.showDialog = showCollectorDialog
      },
      fieldValues: {
        components: [this.componentValue],
        email: this.element.dataset.email || ""
      }
    }
  }

  open(event) {
    event.preventDefault()
    if (this.showDialog) {
      this.showDialog()
    }
  }
}
