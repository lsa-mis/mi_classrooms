import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    'panorama', 'panoramatext', 'roomimage', 'roomimagetext',
    'galleryimage1', 'galleryimage1text',
    'galleryimage2', 'galleryimage2text',
    'galleryimage3', 'galleryimage3text',
    'galleryimage4', 'galleryimage4text',
    'galleryimage5', 'galleryimage5text',
    'roomlayout', 'roomlayouttext'
  ]

  deleteroomimage(event) {
    this.roomimageTarget.remove()
    this.roomimagetextTarget.innerHTML = "Image will be removed"
  }

  deletegalleryimage1(event) {
    this.galleryimage1Target.remove()
    this.galleryimage1textTarget.innerHTML = "Image will be removed"
  }

  deletegalleryimage2(event) {
    this.galleryimage2Target.remove()
    this.galleryimage2textTarget.innerHTML = "Image will be removed"
  }

  deletegalleryimage3(event) {
    this.galleryimage3Target.remove()
    this.galleryimage3textTarget.innerHTML = "Image will be removed"
  }

  deletegalleryimage4(event) {
    this.galleryimage4Target.remove()
    this.galleryimage4textTarget.innerHTML = "Image will be removed"
  }

  deletegalleryimage5(event) {
    this.galleryimage5Target.remove()
    this.galleryimage5textTarget.innerHTML = "Image will be removed"
  }

  deleteroomlayout(event) {
    this.roomlayoutTarget.remove()
    this.roomlayouttextTarget.innerHTML = "Image will be removed"
  }

  deletepanorama(event) {
    this.panoramaTarget.remove()
    this.panoramatextTarget.innerHTML = "Image will be removed"
  }
}
