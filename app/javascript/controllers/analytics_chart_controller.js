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
    this.beforeCache = this.beforeCache.bind(this)
    document.addEventListener("turbo:before-cache", this.beforeCache)
    this.renderChart()
  }

  disconnect() {
    document.removeEventListener("turbo:before-cache", this.beforeCache)
    this.destroyChart()
  }

  // Turbo snapshots the page for back/forward; tear down Chart.js first so a
  // cached canvas bitmap is not restored over fresh data on the next visit.
  beforeCache() {
    this.destroyChart()
  }

  renderChart() {
    this.destroyChart()

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

  destroyChart() {
    this.chart?.destroy()
    this.chart = null
  }
}
