require 'rails_helper'

RSpec.describe Strain, type: :model do
  # pending "add some examples to (or delete) #{__FILE__}"

  context "Testing the strains first" do
    it "cannot have the same name" do
      strain_1 = Strain.create(name: 'Merlot')
      strain_2 = Strain.create(name: 'Merlot')
      expect(strain_2).to_not be_valid
    end 
  end

  context "Testing the strains second" do
    it "cannot have a blank name" do
      s = Strain.create(name: "")
      expect(s).to_not be_valid
    end
  end

  context "Testing the strains third" do
    it "cannot have a nil name" do
      st = Strain.create()
      expect(st).to_not be_valid
    end  
  end
end

# bundle exec rspec spec/models/strain_spec.rb