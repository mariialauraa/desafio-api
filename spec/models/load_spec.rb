require 'rails_helper'

RSpec.describe Load, type: :model do
  it { is_expected.to validate_presence_of(:code) }
  it { is_expected.to validate_uniqueness_of(:code).case_insensitive }
  it { is_expected.to validate_presence_of(:delivery_date) }

  it "can't have past delivery_date" do
    subject.delivery_date = 1.day.ago
    subject.valid?
    expect(subject.errors.to_hash.keys).to include :delivery_date
  end

  it "is invalid with current delivery_date" do
    subject.delivery_date = Time.zone.now
    subject.valid?
    expect(subject.errors.to_hash.keys).to include :delivery_date
  end

  it "is valid with future date" do
    subject.delivery_date = Time.zone.now + 1.day
    subject.valid?
    expect(subject.errors.to_hash.keys).to_not include :delivery_date
  end

  it_behaves_like "paginatable concern", :load
end