require "rails_helper"

RSpec.describe Feedback, type: :model do
  subject {
    described_class.new(topic: "Here is a topic", comment: "Anything",
                        email: "tester@example.com")
  }

  it "is valid with valid attributes" do
    expect(subject).to be_valid
  end

  it "is not valid without a topic" do
    subject.topic = nil
    expect(subject).not_to be_valid
  end

  it "is not valid without a comment" do
    subject.comment = nil
    expect(subject).not_to be_valid
  end

  it "is not valid without a email" do
    subject.email = nil
    expect(subject).not_to be_valid
  end

  it "is not valid if email is too long" do
    subject.email = "a" * 244 + "@example.com"
    expect(subject).not_to be_valid
  end

  it "email validation accepts valid addresses" do
    valid_addresses = %w[user@example.com USER@foo.COM A_US-ER@foo.bar.org
                         first.last@foo.jp alice+bob@baz.cn]
    valid_addresses.each do |valid_address|
      subject.email = valid_address
      expect(subject).to be_valid
    end
  end

  it "email validation should reject invalid addresses" do
    invalid_addresses = %w[user@example,com user_at_foo.org user.name@example.
                           foo@bar_baz.com foo@bar+baz.com foo@bar..com]
    invalid_addresses.each do |invalid_address|
      subject.email = invalid_address
      expect(subject).not_to be_valid
    end
  end
end
