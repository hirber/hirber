require "spec_helper"
require "hirber"

Hirb.enable

RSpec.describe "activerecord table" do
  context "with no select" do
    let(:pet) do
      double(
        name: "rufus",
        age: 7,
        attributes: { "name" => "rufus", "age" => 7 },
        class: double(column_names: %w{age name}),
      )
    end

    it "gets default options" do
      expect(Hirb::Helpers::AutoTable.active_record__base_view(pet))
        .to eq(fields: [:age, :name])
    end
  end

  context "with select" do
    let(:pet) do
      double(
        name: "rufus",
        age: 7,
        attributes: { "name" => "rufus" },
        class: double(column_names: %w{age name}),
      )
    end

    it "gets default options" do
      expect(Hirb::Helpers::AutoTable.active_record__base_view(pet))
        .to eq(fields: [:name])
    end
  end
end

RSpec.describe "mongoid table" do
  let(:mongoid_stub) { double(class: double(fields: fields)) }
  let(:fields) { {"_id" => "x0f0x", "name" => "blah"} }

  it "only has one _id" do
    expect(Hirb::Helpers::AutoTable.mongoid__document_view(mongoid_stub))
      .to eq(fields: fields.keys.sort)
  end
end
