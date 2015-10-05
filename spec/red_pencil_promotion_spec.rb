require 'spec_helper'
require './red_pencil_promotion'

describe "RedPencilPromotion" do
  let (:promo) {RedPencilPromotion.new 30, 10}

  describe "new RedPencilPromotion" do
    it "takes two arguments and returns a RedPencilPromotion object" do
      expect(promo).to be_an_instance_of(RedPencilPromotion)
    end

    it "sets the correct discount amount" do
      expect(promo.discount).to eq(30)
    end

    it "sets the correct promo time length in days" do
      expect(promo.runtime).to eq(10)
    end
  end

  describe "valid_discount?" do
    let(:true_promo) {RedPencilPromotion.new 20, 10}
    it "returns true for a discount over 5% but under 30%" do
      expect(true_promo.valid_discount?).to be true
    end

    let(:min_promo) {RedPencilPromotion.new 5, 10}
    it "returns true for a discount at 5%" do
      expect(min_promo.valid_discount?).to be true
    end

    let(:max_promo) {RedPencilPromotion.new 30, 10}
    it "returns true for a discount at 30%" do
      expect(max_promo.valid_discount?).to be true
    end

    let(:low_promo) {RedPencilPromotion.new 2, 10}
    it "returns false for a discount under 5%" do
      expect(low_promo.valid_discount?).to be false
    end

    let(:high_promo) {RedPencilPromotion.new 40, 10}
    it "returns false for a discount over 30%" do
      expect(high_promo.valid_discount?).to be false
    end
  end

  describe "valid_runtime?" do
    it "returns true for runtime between 0 and 30 days" do
      expect(promo.valid_runtime?).to be true
    end

    let(:max_length_promo) {RedPencilPromotion.new 30, 30}
    it "returns true for runtime of 30 days" do
      expect(max_length_promo.valid_runtime?).to be true
    end

    let(:long_promo) {RedPencilPromotion.new 30, 31} 
    it "returns false for runtime over 30 days" do
      expect(long_promo.valid_runtime?).to be false
    end

    let(:short_promo) {RedPencilPromotion.new 30, -1}
    it "returns false for runtime under 0" do
      expect(short_promo.valid_runtime?).to be false
    end
  end

  describe "price_change" do
    it "returns the correct amount to be added to total price" do
      expect(promo.price_change 100.00).to eq(-30)
    end
  end

  describe "react_to_price_change" do
    let (:temp_product) {Product.new "temp", 100.00}
    let (:red_pencil1) {RedPencilPromotion.new 30, 10}
    let (:red_pencil2) {RedPencilPromotion.new 30, 10}

    it "does not end a promotion if price decreases less than 30%" do
      red_pencil1.react_to_price_change 100.00, 80.00
      expect(red_pencil1.active?).to be true
    end

    it "ends a promotion if the price increases" do
      red_pencil1.react_to_price_change 50.00, 100.00 
      expect(red_pencil1.active?).to be false
    end

    it "ends promotion if price decreases more than 30%" do
      red_pencil2.react_to_price_change 100.00, 69.00
      expect(red_pencil2.active?).to be false
    end
  end

  describe "active?" do
    let (:red_pencil) {RedPencilPromotion.new 30, 10}

    it "returns true for an active promotion" do
      expect(red_pencil.active?).to be true
    end

    it "returns false for a promotion that has expired" do
      allow(Time).to receive(:now).and_return(red_pencil.start_date + red_pencil.runtime.days)
      expect(red_pencil.active?).to be false
    end

    it "returns false for a promotion that has been ended" do
      red_pencil.end
      expect(red_pencil.active?).to be false
    end
  end

  describe "end" do
    let (:red_pencil) {RedPencilPromotion.new 30, 10}

    it "updates end date for promotion" do
      original_ended_on = red_pencil.ended_on
      red_pencil.end
      expect(red_pencil.ended_on).not_to eq(original_ended_on)
    end
  end

  describe "eligible_product?" do
    let (:red_pencil) {RedPencilPromotion.new 30, 10}
    let (:product) {Product.new "stuff", 1.00}

    it "returns true if price has been stable for over 30 days" do
      allow(Time).to receive(:now).and_return(product.price_changed_on + 31.days)
      expect(red_pencil.eligible_product?(product)).to be true
    end

    it "returns true if price has been stable for exactly 30 days" do
      allow(Time).to receive(:now).and_return(product.price_changed_on + 30.days)
      expect(red_pencil.eligible_product?(product)).to be true
    end

    it "returns false if price has been stable for less than 30 days" do 
      allow(Time).to receive(:now).and_return(product.price_changed_on + 1.day)
      expect(red_pencil.eligible_product?(product)).to be false
    end

    it "returns false if red line promotion has been in effect in the last 30 days" do
      product.add_price_modifier(red_pencil)
      expect(red_pencil.eligible_product?(product)).to be false
    end

    it "returns true if no red line promotion has been in effect in the last 30 days and product is otherwise elgibile" do
      allow(Time).to receive(:now).and_return(product.price_changed_on + 41.days)
      expect(red_pencil.eligible_product?(product)).to be true
    end
  end
end
