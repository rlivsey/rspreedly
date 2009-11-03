module RSpreedly
  module PaymentMethod
    class CreditCard < Base
      attr_accessor :number, :verification_value, :month, 
                    :year, :first_name, :last_name, :card_type,
                    :address1, :address2, :city, :state, :zip, :country,
                    :phone_number
    end
  end
end