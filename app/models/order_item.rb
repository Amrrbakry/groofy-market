class OrderItem < ApplicationRecord
  belongs_to :item
  belongs_to :order

  validates :quantity, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validate :item_present
  validate :order_present
  validate :check_required_options

  before_save :finalize

  include CartsHelper

  def unit_price
    if persisted?
      self[:unit_price]
    else
      item.price
    end
  end

  # extras hold the ids of option values selected for the order item
  def total_additional_charge
    sum = 0
    unless extras.empty?
      extras.each do |value_id|
        value_charge = find_value(value_id).additional_charge
        sum += value_charge
      end
    end
    sum
  end

  def total_price
    (unit_price * quantity) + total_additional_charge
  end

  private

  def item_present
    errors.add(:item, "is not valid") if item.nil?
  end

  def order_present
    errors.add(:order, "is not a valid order") if order.nil?
  end

  def finalize
    self[:unit_price] = unit_price
    self[:total_price] = total_price
  end

  # if not at least one value of a required option is present in extras
  # then this required option is not selectd (validation error)
  def check_required_options
    item.options.each do |o|
      if o.required?
        errors.add(o.name.to_s, "is required") if o.values.select { |v| extras.include?(v.id.to_s) }.empty?
      end
    end
  end
end
