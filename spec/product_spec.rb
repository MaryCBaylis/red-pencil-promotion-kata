require 'spec_helper'
require './product'
require './red_pencil_promotion'

describe "Product" do
  let(:current_time) {Time.now}
  let(:product) {Product.new("Best book ever!", 1.50)}
  
  describe "new Product" do
    it "takes 3 arguments and returns a Product object" do
      expect(product).to be_an_instance_of(Product)
    end

    it "sets the correct name" do
      expect(product.name).to eq("Best book ever!")
    end

    it "sets the correct price" do
      expect(product.price).to eq(1.50)
    end

    it "sets the price_changed_on to reasonable time" do
      expect(product.price_changed_on).to be_within(1.min).of(current_time)
    end
  end


  describe "eligible_for_promo?" do
    let (:red_line) {RedPencilPromotion.new 30, 10}

    it "returns true if product is eligible for promo" do
      allow(red_line).to receive(:eligible_product?).and_return(true)
      expect(product.eligible_for_promo?(red_line)).to be true
    end

    it "returns false if product is not eligible for promo" do
      allow(red_line).to receive(:eligible_product?).and_return(false)
      expect(product.eligible_for_promo?(red_line)).to be false
    end
  end

  describe "add_price_modifier" do
    let (:red_pencil) {RedPencilPromotion.new 30, 10}
    let (:temp_product) {Product.new "temp", 100.00}

    it "adds a price modifier object to product's list of price_modifier" do
      temp_product.add_price_modifier(red_pencil)
      expect(temp_product.price_modifiers.any? {|mod| mod.instance_of? RedPencilPromotion}).to be true
    end
  end

  describe "update_price_changed_on" do
    it "updates the product's price_changed_on date" do
      original_price_change_date = product.price_changed_on
      product.update_price_changed_on
      expect(product.price_changed_on).not_to eq(original_price_change_date)
    end
  end

  describe "modified_price" do
    let (:temp_product) {Product.new "temp", 100.00}
    let (:red_pencil) {RedPencilPromotion.new 30, 10}

    it "returns correct price for product with no modifiers" do
      expect(temp_product.modified_price).to eq(temp_product.price)
    end

    it "returns correctly discounted price for product with price modifier" do
      temp_product.add_price_modifier(red_pencil)
      expect(temp_product.modified_price).to eq(70.00)
    end
  end

  describe "price=" do
    let (:temp_product) {Product.new "temp", 100.00}
    let (:red_pencil) {RedPencilPromotion.new 30, 10}

    it "sets the correct price" do
      temp_product.price = 10.00
      expect(temp_product.price).to eq(10)
    end

    it "updates the price_changed_on date" do
      original_price_change_date = temp_product.price_changed_on
      temp_product.price = 20.00
      expect(temp_product.price_changed_on).not_to eq(original_price_change_date)
    end

    it "notifies price modifiers of a change in price" do
      allow(temp_product).to receive(:price_changed_on).and_return(Time.now - 31.days)
      temp_product.add_price_modifier(red_pencil)
      temp_product.price = 200.00
      expect(temp_product.price_modifiers.any? {|mod| mod.active?}).to be false
    end
  end
end