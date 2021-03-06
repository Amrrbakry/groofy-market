require 'test_helper'

class ValueTest < ActiveSupport::TestCase
  def setup
    @item = Item.first
    @option = @item.options.create!(name: "o1", description: "od1")
    @value = @option.values.build(name: "value1", additional_charge: 5.00)
  end

  test "value is valid" do
    assert @value.valid?
  end

  test "name is present" do
    @value.name = nil
    assert_not @value.valid?
  end

  test "value's additional_charge defaults to 0.00 if not specified" do
    value = @option.values.build(name: "V1")
    assert value.additional_charge == 0.00
  end

  test "value's additional_charge is number" do
    @value.additional_charge = "abc"
    assert_not @value.valid?
  end

  test "value's additional_charge is greater than zero" do
    @value.additional_charge = -2
    assert_not @value.valid?
  end
end
