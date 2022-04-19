import { Controller } from 'stimulus'

export default class extends Controller {
  static targets = ['room_image', 'gallery_image1', 'gallery_image2', 'gallery_image3', 'gallery_image4', 'gallery_image5',
    'room_image_file', 'gallery_image1_file', 'gallery_image2_file', 'gallery_image3_file', 'gallery_image4_file', 'gallery_image5_file',
    'imagetext', 'image1text', 'image2text', 'image3text', 'image4text', 'image5text']

  tobedeletedRoomImage(event) {
    let confirmed0 = confirm("Are you sure?")
    if (confirmed0) {
      console.log("yes")
      this.room_imageTarget.remove()
      this.room_image_fileTarget.remove()
      this.imagetextTarget.innerHTML = "Delete on Save"
    }
    else {
      console.log("prevent")
      event.preventDefault()
    }
  }

  tobedeletedGalleryImage1(event) {
    let confirmed1 = confirm("Are you sure?")
    if (confirmed1) {
      this.gallery_image1Target.remove()
      this.gallery_image1_fileTarget.remove()
      this.image1textTarget.innerHTML = "Delete on Save"
    }
    else {
      event.preventDefault()
    }
  }

  tobedeletedGalleryImage2(event) {
    let confirmed2 = confirm("Are you sure?")
    if (confirmed2) {
      this.gallery_image2Target.remove()
      this.gallery_image2_fileTarget.remove()
      this.image2textTarget.innerHTML = "Delete on Save"
    }
    else {
      event.preventDefault()
    }
  }

  tobedeletedGalleryImage3(event) {
    let confirmed3 = confirm("Are you sure?")
    if (confirmed3) {
      this.gallery_image3Target.remove()
      this.gallery_image3_fileTarget.remove()
      this.image3textTarget.innerHTML = "Delete on Save"
    }
    else {
      event.preventDefault()
    }
  }

  tobedeletedGalleryImage4(event) {
    let confirmed4 = confirm("Are you sure?")
    if (confirmed4) {
      this.gallery_image4Target.remove()
      this.gallery_image4_fileTarget.remove()
      this.image4textTarget.innerHTML = "Delete on Save"
    }
    else {
      event.preventDefault()
    }
  }

  tobedeletedGalleryImage5(event) {
    let confirmed5 = confirm("Are you sure?")
    if (confirmed5) {
      this.gallery_image5Target.remove()
      this.gallery_image5_fileTarget.remove()
      this.image5textTarget.innerHTML = "Delete on Save"
    }
    else {
      event.preventDefault()
    }
  }

}
