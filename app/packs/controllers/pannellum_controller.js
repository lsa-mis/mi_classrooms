// import { Controller } from "stimulus"
// require('pannellum')
// import 'pannellum/src/css/pannellum.css';

// export default class extends Controller {
//   static targets = [ "panorama" ]

//   connect(){
//     console.log("In Connect")
//     console.log(this.data)
//     let panoImage = this.data.get("panoimage")
//     let panoPreview = this.data.get("panopreview")
//     this.pano(panoImage, panoPreview)
//   }
//   pano(panoImage, panoPreview) {

//     pannellum.viewer('panorama', {
//       "type": "equirectangular",
//       "panorama": panoImage,
//       "preview": panoPreview
//     });
//   }
// }