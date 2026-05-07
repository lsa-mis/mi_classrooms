require "rails_helper"

RSpec.describe RoomCharacteristicDecorator do
  describe "#characteristic_icon" do
    it "returns an icon class for known short descriptions" do
      characteristic = RoomCharacteristic.new(chrstc_descrshort: "ProjDigit")
      decorator = described_class.decorate(characteristic)

      expect(decorator.characteristic_icon).to eq("fas fa-video")
    end
  end

  describe "#characteristic_label" do
    it "normalizes known prefixes" do
      board = described_class.decorate(RoomCharacteristic.new(chrstc_descr: "Board:Whiteboard"))
      ethernet = described_class.decorate(RoomCharacteristic.new(chrstc_descr: "Ethernet Connection:Wired"))
      blank = described_class.decorate(RoomCharacteristic.new(chrstc_descr: nil))

      expect(board.characteristic_label).to eq("Whiteboard")
      expect(ethernet.characteristic_label).to eq("Ethernet:Wired")
      expect(blank.characteristic_label).to eq("missing")
    end

    it "returns original text when no prefix rule matches" do
      characteristic = described_class.decorate(RoomCharacteristic.new(chrstc_descr: "General Feature"))

      expect(characteristic.characteristic_label).to eq("General Feature")
    end
  end
end
