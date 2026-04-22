require "rails_helper"

RSpec.describe ProcessThumbnailJob, type: :job do
  describe "#perform" do
    it "processes the room image thumbnail when an image is attached" do
      blob = instance_double(ActiveStorage::Blob, present?: true)
      variant = instance_double("ActiveStorage::Variant", processed: true)
      attachment = double("room_image", attached?: true, blob: blob)
      room = instance_double(Room, room_image: attachment)

      allow(attachment).to receive(:representation)
        .with(resize_to_fill: [150, 150], format: :webp)
        .and_return(variant)

      described_class.perform_now(room)

      expect(attachment).to have_received(:representation)
        .with(resize_to_fill: [150, 150], format: :webp)
      expect(variant).to have_received(:processed)
    end

    it "does nothing when no image is attached" do
      attachment = double("room_image", attached?: false)
      room = instance_double(Room, room_image: attachment)

      expect { described_class.perform_now(room) }.not_to raise_error
    end
  end
end
