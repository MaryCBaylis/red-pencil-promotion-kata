require_relative 'helper'

class Product
  attr_reader :name, :price_changed_on, :price, :price_modifiers

  def initialize(name, price)
    @name = name
    @price = price
    @price_changed_on = Time.now
    @price_modifiers = []
  end

  def eligible_for_promo?
    @price_changed_on + 30.days <= Time.now
  end

  def add_price_modifier(modifier)
    @price_modifiers << modifier.dup
    update_price_changed_on
  end

  def update_price_changed_on
    @price_changed_on = Time.now
  end

  def modified_price
    result = @price
    #This comment is here only because the instructions of the kata can be kind of ambiguous.  I understood "If the price is further reduced during the red pencil promotion the promotion will not be prolonged by that reduction." to mean that the price of the product will not be reduced by any other promotions if the red_pencil promo is active, although the word prolonged means to extend in time.  I'm not sure how any promo would extend any other price modifier's start or end time, so I'm thinking that's just a poor choice of words.
    if @price_modifiers.any? {|modifier| modifier.instance_of? RedPencilPromotion}
      @price_modifiers.select {|modifier| result += modifier.price_change @price }
    else
      @price_modifiers.map {|modifier| result += modifier.price_change @price}
    end
    result
  end

  def price=(new_price)
    @price_modifiers.map {|mod| mod.react_to_price_change @price, new_price}
    @price = new_price
    @price_changed_on = Time.now
  end
end