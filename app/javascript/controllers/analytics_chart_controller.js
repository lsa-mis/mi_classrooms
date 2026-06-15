import { Controller } from "@hotwired/stimulus"
import { Chart } from "chart.js"

// chart.js/auto is bundled — all chart types are pre-registered.
export default class extends Controller {
  static values = {
    type: String,
    labels: Array,
    datasets: Array,
    title: String
  }

  connect() {
    const ctx = this.element.getContext("2d")

    this.chart = new Chart(ctx, {
      type: this.typeValue,
      data: {
        labels: this.labelsValue,
        datasets: this.datasetsValue
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        plugins: {
          legend: { position: "bottom" },
          title: {
            display: !!this.titleValue,
            text: this.titleValue
          }
        },
        scales: {
          x: { grid: { display: false } },
          y: { beginAtZero: true, ticks: { precision: 0 } }
        }
      }
    })
  }

  disconnect() {
    this.chart?.destroy()
  }
}
