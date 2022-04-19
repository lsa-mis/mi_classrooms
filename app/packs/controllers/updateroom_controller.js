import { Controller } from 'stimulus'

export default class extends Controller {
  static targets = ['room_image', 'gallery_image1', 'gallery_image2', 'gallery_image3', 'gallery_image4', 'gallery_image5',
    'room_image_file', 'gallery_image1_file', 'gallery_image2_file', 'gallery_image3_file', 'gallery_image4_file', 'gallery_image5_file',
    'imagetext', 'image1text', 'image2text', 'image3text', 'image4text', 'image5text']

  tobedeletedRoomImage(event) {
    this.room_imageTarget.remove()
    this.room_image_fileTarget.remove()
    this.imagetextTarget.innerHTML = "Delete on Save"
  }

  tobedeletedGalleryImage1(event) {
    this.gallery_image1Target.remove()
    this.gallery_image1_fileTarget.remove()
    this.image1textTarget.innerHTML = "Delete on Save"
  }

  tobedeletedGalleryImage2(event) {
    this.gallery_image2Target.remove()
    this.gallery_image2_fileTarget.remove()
    this.image2textTarget.innerHTML = "Delete on Save"
  }

  tobedeletedGalleryImage3(event) {
    this.gallery_image3Target.remove()
    this.gallery_image3_fileTarget.remove()
    this.image3textTarget.innerHTML = "Delete on Save"
  }

  tobedeletedGalleryImage4(event) {
    this.gallery_image4Target.remove()
    this.gallery_image4_fileTarget.remove()
    this.image4textTarget.innerHTML = "Delete on Save"
  }

  tobedeletedGalleryImage5(event) {
    this.gallery_image5Target.remove()
    this.gallery_image5_fileTarget.remove()
    this.image5textTarget.innerHTML = "Delete on Save"
  }

}
