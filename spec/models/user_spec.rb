require 'rails_helper'

RSpec.describe User, type: :model do
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_presence_of(:login) }
  it { is_expected.to validate_uniqueness_of(:login).case_insensitive }   

  it_behaves_like "like searchable concern", :user, :name
  it_behaves_like "paginatable concern", :user
end