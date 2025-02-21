module Spree
    module StockMovementDecorator
      def self.prepended(base)
      
        base.after_commit :update_product_stock_status, on: [:create, :update]
      end

      

    private

    def update_product_stock_status
      stock_item.product.update_outofstock_taxon if stock_item.present?
    end
  
     
    end
  
    StockMovement.prepend(StockMovementDecorator)
  end