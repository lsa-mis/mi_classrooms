// This file uses explicit imports instead of require.context()
// This is compatible with esbuild and modern JavaScript bundlers

import { Application } from "@hotwired/stimulus"

// Custom controllers
import AutosubmitController from "./autosubmit_controller"
import CapacitySliderController from "./capacity_slider_controller"
import ConfirmationController from "./confirmation_controller"
import FeedbackController from "./feedback_controller"
import FlashController from "./flash_controller"
import InfopanelController from "./infopanel_controller"
import MobileMenuController from "./mobile_menu_controller"
import PannellumController from "./pannellum_controller"
import UpdatebuildingController from "./updatebuilding_controller"
import UpdateroomController from "./updateroom_controller"
import VisibilityController from "./visibility_controller"

// Third-party Stimulus components
import { Alert, Autosave, Dropdown, Modal, Tabs, Popover, Toggle, Slideover } from "tailwindcss-stimulus-components"
import Flatpickr from "stimulus-flatpickr"
import Lightbox from "stimulus-lightbox"

const application = Application.start()

// Register custom controllers
application.register("autosubmit", AutosubmitController)
application.register("capacity-slider", CapacitySliderController)
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
application.register("flatpickr", Flatpickr)
application.register("lightbox", Lightbox)

export { application }
