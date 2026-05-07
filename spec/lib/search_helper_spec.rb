require "rails_helper"

RSpec.describe SearchHelper, type: :helper do
  describe "#capacity_slider_minimum" do
    it "defaults to 1 without params" do
      allow(helper).to receive(:params).and_return(ActionController::Parameters.new)

      expect(helper.capacity_slider_minimum).to eq(1)
    end

    it "uses min_capacity param when present" do
      allow(helper).to receive(:params).and_return(ActionController::Parameters.new(min_capacity: "45"))

      expect(helper.capacity_slider_minimum).to eq("45")
    end
  end

  describe "#capacity_slider_maximum" do
    it "defaults to 600 without building filter" do
      allow(helper).to receive(:params).and_return(ActionController::Parameters.new)

      expect(helper.capacity_slider_maximum).to eq(600)
    end

    it "uses max_capacity when building_name is present" do
      allow(helper).to receive(:params).and_return(ActionController::Parameters.new(building_name: "Chem", max_capacity: "120"))

      expect(helper.capacity_slider_maximum).to eq("120")
    end
  end

  describe "#room_characteristic_icon" do
    it "returns mapped icon and defaults when unknown" do
      mapped = RoomCharacteristic.new(chrstc_descrshort: "ProjDigit")
      unknown = RoomCharacteristic.new(chrstc_descrshort: "UnknownCode")

      expect(helper.room_characteristic_icon(mapped)).to eq("video")
      expect(helper.room_characteristic_icon(unknown)).to eq("info-circle")
    end
  end
end
