module RSpreedly

  class Subscriber < Base

    attr_accessor :active,
                  :active_until,
                  :billing_first_name,
                  :billing_last_name,
                  :card_expires_before_next_auto_renew,
                  :created_at,
                  :customer_id,
                  :eligible_for_free_trial,
                  :email,
                  :feature_level,
                  :grace_until,
                  :in_grace_period,
                  :lifetime_subscription,
                  :new_customer_id,
                  :on_trial,
                  :payment_method,
                  :ready_to_renew,
                  :ready_to_renew_since,
                  :recurring,
                  :screen_name,
                  :store_credit,
                  :store_credit_currency_code,
                  :subscription_plan_name,
                  :token,
                  :updated_at

    class << self

      # Get a subscriber’s details
      # GET /api/v4/[short site name]/subscribers/[subscriber id].xml    
      def find(id)      
        return all if id == :all

        begin
          data = api_request(:get, "/subscribers/#{id}.xml")
          Subscriber.new(data["subscriber"])
        rescue RSpreedly::Error::NotFound
          nil
        end
      end

      # Get a list of all subscribers (more)
      # GET /api/v4/[short site name]/subscribers.xml    
      def all
        response = api_request(:get, "/subscribers.xml")
        return [] unless response.has_key?("subscribers")
        response["subscribers"].collect{|data| Subscriber.new(data)}
      end

      # Clear all subscribers from a *test* site (more)
      # DELETE /api/v4/[short site name]/subscribers.xml
      def delete_all
        !! api_request(:delete, "/subscribers.xml")      
      end

      alias_method :destroy_all, :delete_all

    end

    def new_record?
      !self.token
    end

    def save
      self.new_record? ? self.create : self.update
    end

    def save!
      self.new_record? ? self.create! : self.update!
    end

    # Create a subscriber (more)
    # POST /api/v4/[short site name]/subscribers.xml    
    def create!
      result = api_request(:post, "/subscribers.xml", :body => self.to_xml)
      self.attributes = result["subscriber"]
      true
    end

    def create
      begin
        create!
      rescue RSpreedly::Error::Base
        # gulp those errors down
        # TODO - set self.errors or something?
        nil
      end
    end

    # Update a Subscriber (more)
    # PUT /api/v4/[short site name]/subscribers/[subscriber id].xml    
    def update!
      !! api_request(:put, "/subscribers/#{self.customer_id}.xml", :body => self.to_xml(:exclude => [:customer_id]))
    end

    def update
      begin
        update!
      rescue RSpreedly::Error::Base
        # gulp those errors down
        # TODO - set self.errors or something?
        nil
      end      
    end

    # Delete one subscriber from a *test* site (more)
    # DELETE /api/v4/[short site name]/subscribers/[subscriber id].xml    
    def destroy
      begin
        !! api_request(:delete, "/subscribers/#{self.customer_id}.xml")
      rescue RSpreedly::Error::NotFound
        nil
      end      
    end
    alias_method :delete, :destroy

    # Give a subscriber a complimentary subscription (more)
    # POST /api/v4/[short site name]/subscribers/[subscriber id]/complimentary_subscriptions.xml    
    def comp_subscription(subscription)
      result = api_request(:post, "/subscribers/#{self.customer_id}/complimentary_subscriptions.xml", :body => subscription.to_xml)
      self.attributes = result["subscriber"]
      true
    end

    # Give a subscriber a complimentary time extension (more)
    # POST /api/v4/[short site name]/subscribers/[subscriber id]/complimentary_time_extension.xml
    def comp_time_extension(extension)
      result = api_request(:post, "/subscribers/#{self.customer_id}/complimentary_time_extensions.xml", :body => extension.to_xml)
      self.attributes = result["subscriber"]
      true
    end

    # Give a subscriber a credit (or reduce credit by supplying a negative value (more)
    # POST /api/v4[short site name]/subscribers/[subscriber id]/credit.xml
    def credit(amount)
      credit = Credit.new(:amount => amount)
      result = api_request(:post, "/subscribers/#{self.customer_id}/credit.xml", :body => credit.to_xml)
      self.store_credit = (self.store_credit || 0) + amount
      true
    end

    # Programatically Stopping Auto Renew of a Subscriber (more)
    # POST /api/v4/[short site name]/subscribers/[subscriber id]/stop_auto_renew.xml
    def stop_auto_renew
      !! api_request(:post, "/subscribers/#{self.customer_id}/stop_auto_renew.xml")
    end

    # Programatically Subscribe a Subscriber to a Free Trial Plan (more)
    # POST /api/v4/[short site name]/subscribers/[subscriber id]/subscribe_to_free_trial.xml
    def subscribe_to_free_trial(plan)
      result = api_request(:post, "/subscribers/#{self.customer_id}/subscribe_to_free_trial.xml", :body => plan.to_xml)
      self.attributes = result["subscriber"]
      true      
    end

    # Programatically Allow Another Free Trial (more)
    # POST /api/v4/[short site name]/subscribers/[subscriber id]/allow_free_trial.xml
    def allow_free_trial
      result = api_request(:post, "/subscribers/#{self.customer_id}/allow_free_trial.xml")
      self.attributes = result["subscriber"]
      true            
    end
    
    def grant_lifetime_subscription(feature_level)
      subscription = LifetimeComplimentarySubscription.new(:feature_level => feature_level)
      result = api_request(:post, "/subscribers/#{self.customer_id}/lifetime_complimentary_subscriptions.xml", :body => subscription.to_xml)
      self.attributes = result["subscriber"]
      true
    end
    
    def to_xml(opts={})
      
      # the api doesn't let us send these things
      # so let's strip them out of the XML
      exclude = [
        :active,       :active_until,               :card_expires_before_next_auto_renew, 
        :created_at,   :eligible_for_free_trial,    :feature_level, 
        :grace_until,  :in_grace_period,            :lifetime_subscription, 
        :on_trial,     :ready_to_renew,             :recurring, 
        :store_credit, :store_credit_currency_code, :subscription_plan_name,   
        :token,        :updated_at
      ]
      
      opts[:exclude] ||= []
      opts[:exclude] |= exclude
      
      super(opts)      
    end
  end
end