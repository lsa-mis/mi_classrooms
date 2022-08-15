import { Controller } from "stimulus"
require('pannellum-rooms')
export default class extends Controller {
  static targets = [ "panorama" ]

  connect(){
    let panoImage = this.data.get("panoimage")
    let panoPreview = this.data.get("panopreview")
    this.pano(panoImage, panoPreview)
  }
  pano(panoImage, panoPreview) {

    pannellum.viewer('panorama', {
      "type": "equirectangular",
      "panorama": panoImage,
      "preview": panoPreview
    });
  }

}
