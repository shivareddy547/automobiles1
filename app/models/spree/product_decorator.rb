module Spree
    module ProductDecorator
      def self.prepended(base)
      
        base.after_commit :update_outofstock_taxon, on: [:create, :update]
      end

      def update_outofstock_taxon
        outofstock_taxon = Spree::Taxon.find_by(name: "Out of stock Products")
        return unless outofstock_taxon
  
        stock_quantity = stock_items.sum(:count_on_hand)
  
        if stock_quantity < 5
          self.taxons << outofstock_taxon unless self.taxons.include?(outofstock_taxon)
        else
          self.taxons.delete(outofstock_taxon) if self.taxons.include?(outofstock_taxon)
        end
      end
  
     
    end
  
    Product.prepend(ProductDecorator)
  end