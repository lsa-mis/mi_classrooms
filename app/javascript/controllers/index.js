// Stimulus controllers for importmap
// pin_all_from makes controllers available as "controllers/controller_name"

import { Application } from "@hotwired/stimulus"

// Custom controllers
import AutosubmitController from "controllers/autosubmit_controller"
import ConfirmationController from "controllers/confirmation_controller"
import FeedbackController from "controllers/feedback_controller"
import FlashController from "controllers/flash_controller"
import InfopanelController from "controllers/infopanel_controller"
import LightboxController from "controllers/lightbox_controller"
import MobileMenuController from "controllers/mobile_menu_controller"
import PannellumController from "controllers/pannellum_controller"
import UpdatebuildingController from "controllers/updatebuilding_controller"
import UpdateroomController from "controllers/updateroom_controller"
import VisibilityController from "controllers/visibility_controller"

// Third-party Stimulus components
import { Alert, Autosave, Dropdown, Modal, Tabs, Popover, Toggle, Slideover } from "tailwindcss-stimulus-components"

const application = Application.start()

// Register custom controllers
application.register("autosubmit", AutosubmitController)
application.register("confirmation", ConfirmationController)
application.register("feedback", FeedbackController)
application.register("flash", FlashController)
application.register("infopanel", InfopanelController)
application.register("mobile-menu", MobileMenuController)
application.register("pannellum", PannellumController)
application.register("updatebuilding", UpdatebuildingController)
application.register("updateroom", UpdateroomController)
application.register("visibility", VisibilityController)

// Register third-party controllers
application.register("alert", Alert)
application.register("autosave", Autosave)
application.register("dropdown", Dropdown)
application.register("modal", Modal)
application.register("tabs", Tabs)
application.register("popover", Popover)
application.register("toggle", Toggle)
application.register("slideover", Slideover)
application.register("lightbox", LightboxController)

export { application }
