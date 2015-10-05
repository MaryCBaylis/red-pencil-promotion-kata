class RedPencilPromotion
  attr_reader :discount, :runtime, :start_date, :ended_on

  MAX_DISCOUNT = 30
  MIN_DISCOUNT = 5
  MAX_LENGTH = 30

  def initialize(discount_percent, length_in_days, start_date = Time.now)
    @discount = discount_percent
    @runtime = length_in_days
    @start_date = start_date
  end

  def valid_discount?
    @discount >= MIN_DISCOUNT && @discount <= MAX_DISCOUNT
  end

  def eligible_product?(product)
    past_red_pencil_promos = product.price_modifiers.select {|mod| mod.instance_of? RedPencilPromotion}
    past_red_pencil_promos.select {|promo| promo.ended_on || promo.start_date + runtime < Time.now - 30.days}
    product.price_changed_on + 30.days <= Time.now
  end

  def valid_runtime?
    @runtime >= 0 && @runtime <= MAX_LENGTH
  end

  def price_change(original_price)
    - (original_price * @discount / 100)
  end

  def end
    @ended_on = Time.now
  end

  def active?
    @ended_on.nil? && start_date + @runtime.days > Time.now
  end

  def react_to_price_change(old_price, new_price)
    if old_price < new_price || 0.7 * old_price > new_price
      @ended_on = Time.now
    end
  end
end