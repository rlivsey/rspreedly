module RSpreedly

  class Transaction < Base

    attr_accessor :active,
                  :amount,
                  :created_at,
                  :currency_code,
                  :description,
                  :detail_type,
                  :expires,
                  :id,
                  :invoice_id,
                  :start_time,
                  :terms,
                  :updated_at,
                  :price,
                  :subscriber_customer_id,
                  :detail

    class << self

      # Get a list of 50 transactions
      # Passing :since => id will get the 50 transactions since that one
      # GET /api/v4/[short site name]/transactions.xml
      def all(opts={})
        query_opts = {}
        if opts[:since]
          query_opts[:query] = {:since_id => opts[:since]}
        end

        response = api_request(:get, "/transactions.xml", query_opts)
        return [] unless response.has_key?("transactions")
        response["transactions"].collect{|data| Transaction.new(data)}
      end

    end
  end
end