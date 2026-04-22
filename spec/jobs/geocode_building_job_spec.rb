require "rails_helper"

RSpec.describe GeocodeBuildingJob, type: :job do
  describe "#perform" do
    it "updates building coordinates from geocoder results" do
      building = create(
        :building,
        bldrecnbr: 8_000_101,
        address: "500 S State St",
        city: "Ann Arbor",
        zip: "48109",
        latitude: nil,
        longitude: nil
      )

      allow(Geocoder).to receive(:coordinates)
        .with("500 S State St Ann Arbor 48109")
        .and_return([42.2808, -83.7430])

      described_class.perform_now(building)

      expect(building.reload.latitude).to eq(42.2808)
      expect(building.longitude).to eq(-83.7430)
    end
  end
end
