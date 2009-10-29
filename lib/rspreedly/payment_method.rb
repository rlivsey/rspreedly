module RSpreedly
  module PaymentMethod
    class CreditCard < Base
      attr_accessor :number, :verification_value, :month, :year, :first_name, :last_name, :card_type
    end
  end
end