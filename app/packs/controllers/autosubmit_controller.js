import { Controller } from 'stimulus'
export default class extends Controller {
  static targets = ['form', 'sidebar', 'min_capacity', 'max_capacity', 'capacity_error', 'range', 'longitude', 'latitude', 'locateButton', 'location_error']

  search() {
    clearTimeout(this.timeout)

    this.timeout = setTimeout(() => {
      this.formTarget.requestSubmit()
      this.sidebarTarget.classList.toggle('-translate-x-full')
    }, 200)
  }

  checkboxSubmit() {
    this.formTarget.requestSubmit()
    this.sidebarTarget.classList.toggle('-translate-x-full')
  }

  locateMe() {
    clearTimeout(this.timeout)
  
    this.timeout = setTimeout(() => {
      if (navigator.geolocation) {
        this.locateButtonTarget.textContent = "Locating...";
        this.location_errorTarget.classList.add("capacity-error--hide")
        this.location_errorTarget.classList.remove("capacity-error--display")
        this.location_errorTarget.innerText = ""
        
        navigator.geolocation.getCurrentPosition(position => {
          this.latitudeTarget.value = position.coords.latitude.toFixed(5);
          this.longitudeTarget.value = position.coords.longitude.toFixed(5);
          this.locationSubmit();
          this.locateButtonTarget.textContent = "Use My Current Location";
        }, error => {
          this.location_errorTarget.classList.add("capacity-error--display")
          this.location_errorTarget.classList.remove("capacity-error--hide")
          this.location_errorTarget.innerText = "Please enable location services"
          this.locateButtonTarget.textContent = "Use My Current Location";
        });
      }
      else {
        this.location_errorTarget.classList.add("capacity-error--display")
        this.location_errorTarget.classList.remove("capacity-error--hide")
        this.location_errorTarget.innerText = "Please enable location services"
      }
    }, 200)
  }
  
  
  locationSubmit() {
    clearTimeout(this.timeout)

    this.timeout = setTimeout(() => {
      if (this.longitudeTarget.value && this.latitudeTarget.value) {
        this.formTarget.requestSubmit()
      }
    }, 200)
  }

  capacitySubmit(event) {
    clearTimeout(this.timeout)

    this.timeout = setTimeout(() => {
      var min_capacity = parseInt(this.min_capacityTarget.value)
      var max_capacity = parseInt(this.max_capacityTarget.value)
      if (min_capacity > max_capacity) {
        this.capacity_errorTarget.classList.add("capacity-error--display")
        this.capacity_errorTarget.classList.remove("capacity-error--hide")
        this.capacity_errorTarget.innerText = "Min should be smaller than Max"
      }
      else {
        this.capacity_errorTarget.classList.add("capacity-error--hide")
        this.capacity_errorTarget.classList.remove("capacity-error--display")
        this.capacity_errorTarget.innerText = ""

        this.formTarget.requestSubmit()
        this.sidebarTarget.classList.toggle('-translate-x-full')
      }
    }, 200)
  }

  sortCapacity() {
    this.formTarget.requestSubmit()
  }

  clearFilters() {
    var url = window.location.pathname
    Turbo.visit(url)
  }
}
