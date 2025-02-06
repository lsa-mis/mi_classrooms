class ProcessThumbnailJob < ApplicationJob
  queue_as :default
  retry_on ActiveStorage::FileNotFoundError, attempts: 3, wait: 5.seconds

  def perform(room)
    return unless room.room_image.attached? && room.room_image.blob.present?

    room.room_image.representation(
      resize_to_fill: [150, 150],
      format: :webp
    ).processed
  end
end
