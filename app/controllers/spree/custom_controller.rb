module Spree
  class CustomController < Spree::StoreController # Change to StoreController
    protect_from_forgery with: :exception # Ensure CSRF protection is enabled

    def modal_data
      product = Spree::Product.find(params[:id])
      action_type = params[:action_type].humanize

      render json: {
        title: action_type,
        product_name: product.name
      }
    end

    def process_product_action
      product = Spree::Product.find(params[:id])
      action_type = params[:action_type]
      quantity = params[:quantity].to_i
    
      if action_type == "update_stock"
        stock_item = product.stock_items.first
        if stock_item
          stock_item.adjust_count_on_hand(quantity)
          updated_stock = stock_item.count_on_hand
        else
          updated_stock = 0
        end
        message = "Stock updated for #{product.name}."
    
      elsif action_type == "buy_now"
        user = spree_current_user || Spree::User.find_by(email: "guest@example.com") || create_guest_user
        payment_method = Spree::PaymentMethod.find_by(type: "Spree::PaymentMethod::Check") 
      
        order = Spree::Order.create!(
          user: user,
          store: Spree::Store.default,
          currency: Spree::Config[:currency],
          state: "cart"
        )
        order.ship_address_id = Spree::Address.last 
        order.bill_address_id = Spree::Address.last    
      
        variant = product.variants&.first
      
        result = Spree::Api::Dependencies.storefront_cart_add_item_service.constantize.call(
          order: order,
          variant: variant,
          quantity: quantity,
          options: {}
        )
      
        order.updater.update
        order.reload
      
        payment = order.payments.create!(
          amount: order.total,
          payment_method: payment_method
        )
        payment.process!
      
        order.next! while order.can_next?
      
        updated_stock = product.stock_items.first.try(:count_on_hand) || 0
        message = "Successfully purchased #{quantity} of #{product.name}. Your order ##{order.number} is complete."
        product.update_outofstock_taxon
        # return render json: { message: message, product_id: product.id, updated_stock: updated_stock }
      end      
    
      render json: { message: message, product_id: product.id, updated_stock: updated_stock }
    end
    
    
    private
    
    # Creates a guest user if no logged-in user is available
    def create_guest_user
      password = SecureRandom.hex(8)
      user = Spree::User.create!(
        email: "guest#{Time.now.to_i}@example.com",
        password: password,
        password_confirmation: password
      )
      user
    end
    
    
  end
end
