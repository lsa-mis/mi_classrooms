import { Controller } from 'stimulus'

export default class extends Controller {
  static targets = ['room-panorama', 'room_image', 'gallery_image1', 'gallery_image2', 'gallery_image3', 'gallery_image4', 'gallery_image5']

  tobedeletedRoomPanorama(event) {
    let confirmed = confirm("Are you sure?")
    if (confirmed) {
      location.reload()
    }
    else {
      event.preventDefault()
    }
  }

  tobedeletedRoomImage(event) {
    let confirmed0 = confirm("Are you sure?")
    if (confirmed0) {
      location.reload()
    }
    else {
      event.preventDefault()
    }
  }

  tobedeletedGalleryImage1(event) {
    let confirmed1 = confirm("Are you sure?")
    if (confirmed1) {
      location.reload()
    }
    else {
      event.preventDefault()
    }
  }

  tobedeletedGalleryImage2(event) {
    let confirmed2 = confirm("Are you sure?")
    if (confirmed2) {
      location.reload()
    }
    else {
      event.preventDefault()
    }
  }

  tobedeletedGalleryImage3(event) {
    let confirmed3 = confirm("Are you sure?")
    if (confirmed3) {
      location.reload()
    }
    else {
      event.preventDefault()
    }
  }

  tobedeletedGalleryImage4(event) {
    let confirmed4 = confirm("Are you sure?")
    if (confirmed4) {
      location.reload()
    }
    else {
      event.preventDefault()
    }
  }

  tobedeletedGalleryImage5(event) {
    let confirmed5 = confirm("Are you sure?")
    if (confirmed5) {
      location.reload()
    }
    else {
      event.preventDefault()
    }
  }

  tobedeletedRoomLayout(event) {
    let confirmed6 = confirm("Are you sure?")
    if (confirmed6) {
      location.reload()
    }
    else {
      event.preventDefault()
    }
  }

}
