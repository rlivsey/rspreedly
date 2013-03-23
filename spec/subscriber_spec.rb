require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
describe RSpreedly::Subscriber do

  describe ".find" do
    describe "with the symbol :all" do
      it "should pass to RSpreedly::Subscriber.all" do
        RSpreedly::Subscriber.should_receive(:all)
        RSpreedly::Subscriber.find(:all)
      end
    end

    it "should return a Subscriber with an email for an existing subscriber" do
      stub_request(:get, spreedly_url("/subscribers.xml")).
        to_return(body: fixture("subscribers.xml"), status: 200)

      subscriber = RSpreedly::Subscriber.find_by_email "new@email.com"
      subscriber.email.should == "new@email.com"
    end

    it "should return an array of Subscriber filtered by email" do
      stub_request(:get, spreedly_url("/subscribers.xml")).
        to_return(body: fixture("subscribers.xml"), status: 200)

      subscribers = RSpreedly::Subscriber.find_by_email nil
      subscribers.class.should == Array
    end

    it "should return nil with an id for a subscriber who doesn't exist" do
      stub_request(:get, spreedly_url("/subscribers/42.xml")).
        to_return(:body => fixture("subscriber_not_found.xml"), :status => 404)

      RSpreedly::Subscriber.find(42).should be_nil
    end

    it "should return a Subscriber with an id for an existing subscriber" do
      stub_request(:get, spreedly_url("/subscribers/42.xml")).
        to_return(:body => fixture("subscriber.xml"), :status => 200)

      RSpreedly::Subscriber.find(42).should be_a(RSpreedly::Subscriber)
    end

    it "should include invoices on the Subscriber" do
      stub_request(:get, spreedly_url("/subscribers/42.xml")).
        to_return(:body => fixture("subscriber.xml"), :status => 200)

      subscriber = RSpreedly::Subscriber.find(42)
      subscriber.invoices.size.should == 5
      subscriber.invoices.select{|x| x.is_a?(RSpreedly::Invoice )}.size.should == 5
    end
  end

  describe ".all" do
    it "should return an empty array if there are no subscribers" do
      stub_request(:get, spreedly_url("/subscribers.xml")).
        to_return(:body => fixture("no_subscribers.xml"), :status => 200)

      RSpreedly::Subscriber.all.should == []
    end

    it "should return an array of subscribers if there are any to find" do
      stub_request(:get, spreedly_url("/subscribers.xml")).
        to_return(:body => fixture("subscribers.xml"), :status => 200)

      RSpreedly::Subscriber.all.size.should == 3 # there are 3 in the fixture
      RSpreedly::Subscriber.all.select{|x| x.is_a?(RSpreedly::Subscriber )}.size.should == 3
    end
  end

  describe ".destroy_all" do
    it "should return true if successful" do
      stub_request(:delete, spreedly_url("/subscribers.xml")).
        to_return(:status => 200)

      RSpreedly::Subscriber.destroy_all.should be_true
    end
  end

  describe "#to_xml" do

    before(:each) do
      # use the XML to build a subscriber
      stub_request(:get, spreedly_url("/subscribers/42.xml")).
        to_return(:body => fixture("subscriber.xml"), :status => 200)

      @subscriber = RSpreedly::Subscriber.find(42)
    end

    it "should strip fields the API can't handle" do
      fields = [
        :active,       :active_until,               :card_expires_before_next_auto_renew,
        :created_at,   :eligible_for_free_trial,    :feature_level,
        :grace_until,  :in_grace_period,            :lifetime_subscription,
        :on_trial,     :ready_to_renew,             :recurring,
        :store_credit, :store_credit_currency_code, :subscription_plan_name,
        :token,        :updated_at
      ]

      xml = @subscriber.to_xml
      fields.each do |field|
        xml.should_not =~ /<#{field}>/
      end
    end

    it "should not strip fields the API can handle" do
      fields = [
        :billing_first_name,
        :billing_last_name,
        :customer_id, :email,
        :screen_name
      ]

      xml = @subscriber.to_xml
      fields.each do |field|
        xml.should =~ /<#{field}>/
      end
    end
  end

  describe "#new_record?" do
    before(:each) do
      @subscriber = RSpreedly::Subscriber.new
    end

    it "should return true if the subscriber doesn't have a token" do
      @subscriber.new_record?.should be_true
    end

    it "should return false if the subscriber has a token" do
      @subscriber.token = "something"
      @subscriber.new_record?.should be_false
    end
  end

  describe "#save" do
    before(:each) do
      @subscriber = RSpreedly::Subscriber.new
    end

    it "should call #create for a non existing subscriber" do
      @subscriber.should_receive(:create)
      @subscriber.save
    end

    it "should call update for an existing subscriber" do
      @subscriber.token = "something"
      @subscriber.should_receive(:update)
      @subscriber.save
    end
  end

  describe "#save!" do
    before(:each) do
      @subscriber = RSpreedly::Subscriber.new
    end

    it "should call #create! for a non existing subscriber" do
      @subscriber.should_receive(:create!)
      @subscriber.save!
    end

    it "should call update! for an existing subscriber" do
      @subscriber.token = "something"
      @subscriber.should_receive(:update!)
      @subscriber.save!
    end
  end

  describe "#create!" do
    it "should return true if successful" do
      stub_request(:post, spreedly_url("/subscribers.xml")).
        to_return(:body => fixture("create_subscriber.xml"), :status => 201)

      @subscriber = RSpreedly::Subscriber.new(:customer_id => 42, :screen_name => "bob")
      @subscriber.create!.should be_true
    end

    it "should raise a BadRequest error if the data is invalid" do
      stub_request(:post, spreedly_url("/subscribers.xml")).
        to_return(:body => fixture("invalid_subscriber.xml"), :status => 422)

      @subscriber = RSpreedly::Subscriber.new
      lambda{
        @subscriber.create!
      }.should raise_error(RSpreedly::Error::BadRequest)
    end

    it "should update the subscriber if successful" do
      stub_request(:post, spreedly_url("/subscribers.xml")).
        to_return(:body => fixture("create_subscriber.xml"), :status => 200)

      @subscriber = RSpreedly::Subscriber.new(:customer_id => 42, :screen_name => "bob")
      lambda{
        @subscriber.create!
      }.should change(@subscriber, :token).to("6af9994a57e420345897b1abb4c27a9db27fa4d0")
    end

    it "should raise a Forbidden error if there is already a subscriber with that ID" do
      stub_request(:post, spreedly_url("/subscribers.xml")).
        to_return(:body => fixture("existing_subscriber.xml"), :status => 403)

      @subscriber = RSpreedly::Subscriber.new(:customer_id => 42, :screen_name => "bob")
      lambda{
        @subscriber.create!
      }.should raise_error(RSpreedly::Error::Forbidden)
    end
  end

  describe "#create" do
    it "should return true if successful" do
      stub_request(:post, spreedly_url("/subscribers.xml")).
        to_return(:body => fixture("create_subscriber.xml"), :status => 201)

      @subscriber = RSpreedly::Subscriber.new
      @subscriber.customer_id = 42
      @subscriber.screen_name = "bob"
      @subscriber.create.should be_true
    end

    it "should return nil if the data is invalid" do
      stub_request(:post, spreedly_url("/subscribers.xml")).
        to_return(:body => fixture("invalid_subscriber.xml"), :status => 422)

      @subscriber = RSpreedly::Subscriber.new
      @subscriber.create.should be_nil
    end

    it "should return nil if there is already a subscriber with that ID" do
      stub_request(:post, spreedly_url("/subscribers.xml")).
        to_return(:body => fixture("existing_subscriber.xml"), :status => 403)

      @subscriber = RSpreedly::Subscriber.new
      @subscriber.customer_id = 42
      @subscriber.screen_name = "bob"
      @subscriber.create.should be_nil
    end
  end

  describe "#update!" do
    before(:each) do
      @subscriber = RSpreedly::Subscriber.new
    end

    describe "with basic information" do
      it "should return true if successful" do
        stub_request(:put, spreedly_url("/subscribers/42.xml")).
          to_return(:status => 200)

        @subscriber.customer_id = 42
        @subscriber.email = "new@email.com"
        @subscriber.update!.should be_true
      end

      it "should raise NotFound if the subscriber doesn't exist" do
        stub_request(:put, spreedly_url("/subscribers/400.xml")).
          to_return(:body => fixture("subscriber_not_found.xml"), :status => 404)

        @subscriber.customer_id = 400
        lambda{
          @subscriber.update!
        }.should raise_error(RSpreedly::Error::NotFound)
      end

      it "should raise BadRequest if the data is invalid" do
        stub_request(:put, spreedly_url("/subscribers/42.xml")).
          to_return(:body => fixture("invalid_update.xml"), :status => 422)

        @subscriber.customer_id = 42
        lambda{
          @subscriber.update!
        }.should raise_error(RSpreedly::Error::BadRequest)
      end
    end

    describe "with new_customer_id" do
      it "should return true if successful" do
        stub_request(:put, spreedly_url("/subscribers/42.xml")).
          to_return(:status => 200)

        @subscriber.customer_id = 42
        @subscriber.new_customer_id = 43
        @subscriber.email = "new@email.com"
        @subscriber.update!.should be_true
      end

      it "should raise NotFound if the subscriber doesn't exist" do
        stub_request(:put, spreedly_url("/subscribers/400.xml")).
          to_return(:body => fixture("subscriber_not_found.xml"), :status => 404)

        @subscriber.customer_id = 400
        @subscriber.new_customer_id = 401
        lambda{
          @subscriber.update!
        }.should raise_error(RSpreedly::Error::NotFound)
      end

      it "should raise BadRequest if the data is invalid" do
        stub_request(:put, spreedly_url("/subscribers/.xml")).
          to_return(:body => fixture("invalid_update.xml"), :status => 422)

        @subscriber.new_customer_id = 43
        lambda{
          @subscriber.update!
        }.should raise_error(RSpreedly::Error::BadRequest)
      end
    end

    describe "with payment information" do
      before(:each) do
        @subscriber.customer_id = 42
        @subscriber.payment_method = RSpreedly::PaymentMethod::CreditCard.new(:number => "1233445", :verification_value => "234")
      end

      it "should return true if successful" do
        stub_request(:put, spreedly_url("/subscribers/42.xml")).
          to_return(:status => 200)

        @subscriber.update!.should be_true
      end

      it "should raise NotFound if the subscriber doesn't exist" do
        stub_request(:put, spreedly_url("/subscribers/42.xml")).
          to_return(:body => fixture("subscriber_not_found.xml"), :status => 404)

        lambda{
          @subscriber.update!
        }.should raise_error(RSpreedly::Error::NotFound)
      end

      it "should raise BadRequest if the data is invalid" do
        stub_request(:put, spreedly_url("/subscribers/42.xml")).
          to_return(:body => fixture("invalid_update.xml"), :status => 422)

        lambda{
          @subscriber.update!
        }.should raise_error(RSpreedly::Error::BadRequest)
      end

      it "should raise Forbidden if the data is invalid" do
        stub_request(:put, spreedly_url("/subscribers/42.xml")).
          to_return(:body => fixture("invalid_update.xml"), :status => 403)

        lambda{
          @subscriber.update!
        }.should raise_error(RSpreedly::Error::Forbidden)
      end
    end
  end

  describe "#update" do
    before(:each) do
      @subscriber = RSpreedly::Subscriber.new
    end

    describe "with basic information" do
      it "should return true if successful" do
        stub_request(:put, spreedly_url("/subscribers/42.xml")).
          to_return(:status => 200)

        @subscriber.customer_id = 42
        @subscriber.email = "new@email.com"
        @subscriber.update!.should be_true
      end

      it "should return nil if the subscriber doesn't exist" do
        stub_request(:put, spreedly_url("/subscribers/400.xml")).
          to_return(:body => fixture("subscriber_not_found.xml"), :status => 404)

        @subscriber.customer_id = 400
        @subscriber.update.should be_nil
      end

      it "should return nil if the data is invalid" do
        stub_request(:put, spreedly_url("/subscribers/42.xml")).
          to_return(:body => fixture("invalid_update.xml"), :status => 422)

        @subscriber.customer_id = 42
        @subscriber.update.should be_nil
      end
    end
  end

  describe "#destroy" do
    before(:each) do
      @subscriber = RSpreedly::Subscriber.new(:customer_id => 42)
    end

    it "should return nil if the subscriber doesn't exist" do
      stub_request(:delete, spreedly_url("/subscribers/42.xml")).
        to_return(:body => fixture("subscriber_not_found.xml"), :status => 404)

      @subscriber.destroy.should be_nil
    end

    it "should return true if successful" do
      stub_request(:delete, spreedly_url("/subscribers/42.xml")).
        to_return(:status => 200)

      @subscriber.destroy.should be_true
    end
  end

  describe "#comp_subscription" do
    before(:each) do
      @subscriber = RSpreedly::Subscriber.new(:customer_id => 42, :feature_level => "Lowly")
      @subscription = RSpreedly::ComplimentarySubscription.new(:duration_quantity => 42, :duration_units => "months", :feature_level => "Pro")
    end

    it "should return true if successful" do
      stub_request(:post, spreedly_url("/subscribers/42/complimentary_subscriptions.xml")).
        to_return(:body => fixture("complimentary_success.xml"), :status => 201)

      @subscriber.comp_subscription(@subscription).should be_true
    end

    it "should update the subscriber if successful" do
      stub_request(:post, spreedly_url("/subscribers/42/complimentary_subscriptions.xml")).
        to_return(:body => fixture("complimentary_success.xml"), :status => 201)

      lambda{
        @subscriber.comp_subscription(@subscription)
      }.should change(@subscriber, :feature_level).to("Pro")
    end

    it "should raise NotFound if the subscriber doesn't exist" do
      stub_request(:post, spreedly_url("/subscribers/42/complimentary_subscriptions.xml")).
        to_return(:body => fixture("subscriber_not_found.xml"), :status => 404)

      lambda{
        @subscriber.comp_subscription(@subscription)
      }.should raise_error(RSpreedly::Error::NotFound)
    end

    it "should raise BadRequest if validation fails on the subscription" do
      stub_request(:post, spreedly_url("/subscribers/42/complimentary_subscriptions.xml")).
        to_return(:body => fixture("complimentary_not_valid.xml"), :status => 422)

      lambda{
        @subscriber.comp_subscription(@subscription)
      }.should raise_error(RSpreedly::Error::BadRequest)
    end

    it "should raise Forbidden if the subscriber is active" do
      stub_request(:post, spreedly_url("/subscribers/42/complimentary_subscriptions.xml")).
        to_return(:body => fixture("complimentary_failed_active.xml"), :status => 403)

      lambda{
        @subscriber.comp_subscription(@subscription)
      }.should raise_error(RSpreedly::Error::Forbidden)
    end
  end

  describe "#comp_time_extension" do
    before(:each) do
      @subscriber = RSpreedly::Subscriber.new(:customer_id => 42, :feature_level => "Lowly")
      @subscription = RSpreedly::ComplimentaryTimeExtension.new(:duration_quantity => 42, :duration_units => "months")
    end

    it "should return true if successful" do
      stub_request(:post, spreedly_url("/subscribers/42/complimentary_time_extensions.xml")).
        to_return(:body => fixture("complimentary_success.xml"), :status => 201)

      @subscriber.comp_time_extension(@subscription).should be_true
    end

    it "should update the subscriber if successful" do
      stub_request(:post, spreedly_url("/subscribers/42/complimentary_time_extensions.xml")).
        to_return(:body => fixture("complimentary_success.xml"), :status => 201)

      lambda{
        @subscriber.comp_time_extension(@subscription)
      }.should change(@subscriber, :active_until).to(Time.parse("Sun Feb 21 19:04:28 UTC 2010"))
    end

    it "should raise NotFound if the subscriber doesn't exist" do
      stub_request(:post, spreedly_url("/subscribers/42/complimentary_time_extensions.xml")).
        to_return(:body => fixture("subscriber_not_found.xml"), :status => 404)

      lambda{
        @subscriber.comp_time_extension(@subscription)
      }.should raise_error(RSpreedly::Error::NotFound)
    end

    it "should raise BadRequest if validation fails on the subscription" do
      stub_request(:post, spreedly_url("/subscribers/42/complimentary_time_extensions.xml")).
        to_return(:body => fixture("complimentary_not_valid.xml"), :status => 422)

      lambda{
        @subscriber.comp_time_extension(@subscription)
      }.should raise_error(RSpreedly::Error::BadRequest)
    end

    it "should raise Forbidden if the subscriber is inactive" do
      stub_request(:post, spreedly_url("/subscribers/42/complimentary_time_extensions.xml")).
        to_return(:body => fixture("complimentary_failed_inactive.xml"), :status => 403)

      lambda{
        @subscriber.comp_time_extension(@subscription)
      }.should raise_error(RSpreedly::Error::Forbidden)
    end
  end

  describe "#credit" do
    before(:each) do
      @subscriber = RSpreedly::Subscriber.new(:customer_id => 42, :feature_level => "Lowly")
      @credit_amount = 5
    end

    it "should return true if successful" do
      stub_request(:post, spreedly_url("/subscribers/42/credit.xml")).
        to_return(:body => fixture("credit_success.xml"), :status => 201)

      @subscriber.credit(@credit_amount).should be_true
      @subscriber.store_credit.should == @credit_amount
    end

    it "should raise NotFound if the subscriber doesn't exist" do
      stub_request(:post, spreedly_url("/subscribers/42/credit.xml")).
        to_return(:body => fixture("subscriber_not_found.xml"), :status => 404)

      lambda{
        @subscriber.credit(@credit_amount)
      }.should raise_error(RSpreedly::Error::NotFound)
    end

    it "should raise BadRequest if validation fails on the subscription" do
      stub_request(:post, spreedly_url("/subscribers/42/credit.xml")).
        to_return(:body => fixture("credit_not_valid.xml"), :status => 422)

      lambda{
        @subscriber.credit(@credit_amount)
      }.should raise_error(RSpreedly::Error::BadRequest)
    end

    it "should increment store_credit" do
      stub_request(:post, spreedly_url("/subscribers/42/credit.xml")).
        to_return(:body => fixture("credit_success.xml"), :status => 201)

      @subscriber.store_credit = 5
      @subscriber.credit(5).should be_true
      @subscriber.store_credit.should == 10
    end

    it "should decrement store_credit" do
      stub_request(:post, spreedly_url("/subscribers/42/credit.xml")).
        to_return(:body => fixture("credit_success.xml"), :status => 201)

      @subscriber.store_credit = 5
      @subscriber.credit(-5).should be_true
      @subscriber.store_credit.should == 0
    end
  end

  describe "#stop_auto_renew" do
    before(:each) do
      @subscriber = RSpreedly::Subscriber.new(:customer_id => 42)
    end

    it "should return true if successful" do
      stub_request(:post, spreedly_url("/subscribers/42/stop_auto_renew.xml")).
        to_return(:status => 200)

      @subscriber.stop_auto_renew.should be_true
    end

    it "should raise NotFound if the subscriber doesn't exist" do
      stub_request(:post, spreedly_url("/subscribers/42/stop_auto_renew.xml")).
        to_return(:body => fixture("subscriber_not_found.xml"), :status => 404)

      lambda{
        @subscriber.stop_auto_renew
      }.should raise_error(RSpreedly::Error::NotFound)
    end
  end

  describe "#subscribe_to_free_trial" do
    before(:each) do
      @subscriber = RSpreedly::Subscriber.new(:customer_id => 42)
      @plan = RSpreedly::SubscriptionPlan.new(:id => 2533)
    end

    it "should return true if successful" do
      stub_request(:post, spreedly_url("/subscribers/42/subscribe_to_free_trial.xml")).
        to_return(:body => fixture("free_plan_success.xml"), :status => 200)

      @subscriber.subscribe_to_free_trial(@plan).should be_true
    end

    it "should update the subscriber if successful" do
      stub_request(:post, spreedly_url("/subscribers/42/subscribe_to_free_trial.xml")).
        to_return(:body => fixture("free_plan_success.xml"), :status => 200)

      lambda{
        @subscriber.subscribe_to_free_trial(@plan)
      }.should change(@subscriber, :grace_until).to(Time.parse("2013-05-02T00:07:37Z"))
    end

    it "should raise NotFound if the subscriber doesn't exist" do
      stub_request(:post, spreedly_url("/subscribers/42/subscribe_to_free_trial.xml")).
        to_return(:body => fixture("subscriber_not_found.xml"), :status => 404)

      lambda{
        @subscriber.subscribe_to_free_trial(@plan)
      }.should raise_error(RSpreedly::Error::NotFound)
    end

    it "should raise NotFound if the plan doesn't exist" do
      stub_request(:post, spreedly_url("/subscribers/42/subscribe_to_free_trial.xml")).
        to_return(:body => fixture("plan_not_found.xml"), :status => 404)

      lambda{
        @subscriber.subscribe_to_free_trial(@plan)
      }.should raise_error(RSpreedly::Error::NotFound)
    end

    it "should raise BadRequest if no plan is specified" do
      stub_request(:post, spreedly_url("/subscribers/42/subscribe_to_free_trial.xml")).
        to_return(:body => fixture("free_plan_not_set.xml"), :status => 422)

      @plan.id = nil
      lambda{
        @subscriber.subscribe_to_free_trial(@plan)
      }.should raise_error(RSpreedly::Error::BadRequest)
    end

    it "should raise Forbidden if the subscriber isn't elligable" do
      stub_request(:post, spreedly_url("/subscribers/42/subscribe_to_free_trial.xml")).
        to_return(:body => fixture("free_plan_not_elligable.xml"), :status => 403)

      lambda{
        @subscriber.subscribe_to_free_trial(@plan)
      }.should raise_error(RSpreedly::Error::Forbidden)
    end

    it "should raise Forbidden if the plan isn't a free trial" do
      stub_request(:post, spreedly_url("/subscribers/42/subscribe_to_free_trial.xml")).
        to_return(:body => fixture("free_plan_not_free.xml"), :status => 403)

      lambda{
        @subscriber.subscribe_to_free_trial(@plan)
      }.should raise_error(RSpreedly::Error::Forbidden)
    end
  end

  describe "#allow_free_trial" do
    before(:each) do
      @subscriber = RSpreedly::Subscriber.new(:customer_id => 42)
    end

    it "should return true if successful" do
      stub_request(:post, spreedly_url("/subscribers/42/allow_free_trial.xml")).
        to_return(:body => fixture("free_plan_success.xml"), :status => 200)

      @subscriber.allow_free_trial.should be_true
    end

    it "should update the subscriber if successful" do
      stub_request(:post, spreedly_url("/subscribers/42/allow_free_trial.xml")).
        to_return(:body => fixture("free_plan_success.xml"), :status => 200)

      lambda{
        @subscriber.allow_free_trial
      }.should change(@subscriber, :grace_until).to(Time.parse("2013-05-02T00:07:37Z"))
    end

    it "should raise NotFound if the subscriber doesn't exist" do
      stub_request(:post, spreedly_url("/subscribers/42/allow_free_trial.xml")).
        to_return(:body => fixture("subscriber_not_found.xml"), :status => 404)

      lambda{
        @subscriber.allow_free_trial
      }.should raise_error(RSpreedly::Error::NotFound)
    end
  end

  describe "#grant_lifetime_subscription" do

    before(:each) do
      @subscriber = RSpreedly::Subscriber.new(:customer_id => 42)
    end

    it "should return true if successful" do
      stub_request(:post, spreedly_url("/subscribers/42/lifetime_complimentary_subscriptions.xml")).
        to_return(:body => fixture("lifetime_subscription_success.xml"), :status => 200)

      @subscriber.grant_lifetime_subscription("Something").should be_true
    end

    it "should update the subscriber's lifetime_subscription if successful" do
      stub_request(:post, spreedly_url("/subscribers/42/lifetime_complimentary_subscriptions.xml")).
        to_return(:body => fixture("lifetime_subscription_success.xml"), :status => 200)

      lambda{
        @subscriber.grant_lifetime_subscription("Something")
      }.should change(@subscriber, :lifetime_subscription).to(true)
    end

    it "should update the subscriber's feature_level if successful" do
      stub_request(:post, spreedly_url("/subscribers/42/lifetime_complimentary_subscriptions.xml")).
        to_return(:body => fixture("lifetime_subscription_success.xml"), :status => 200)

      lambda{
        @subscriber.grant_lifetime_subscription("Something")
      }.should change(@subscriber, :feature_level).to("Something")
    end

    it "should raise NotFound if the subscriber doesn't exist" do
      stub_request(:post, spreedly_url("/subscribers/42/lifetime_complimentary_subscriptions.xml")).
        to_return(:body => fixture("subscriber_not_found.xml"), :status => 404)

      lambda{
        @subscriber.grant_lifetime_subscription("Something")
      }.should raise_error(RSpreedly::Error::NotFound)
    end

    it "should raise BadRequest if the feature level is blank" do
      stub_request(:post, spreedly_url("/subscribers/42/lifetime_complimentary_subscriptions.xml")).
        to_return(:body => fixture("feature_level_blank.xml"), :status => 422)

      lambda{
        @subscriber.grant_lifetime_subscription("Something")
      }.should raise_error(RSpreedly::Error::BadRequest)
    end
    
    it "should return subscribe_link for subscriber without return_url" do
      @subscriber.subscribe_link('99', 'spreedster').should == "https://spreedly.com/your-site-name/subscribers/42/subscribe/99/spreedster"
    end
    
    it "should return subscribe_link for subscriber with return_url" do
      return_url = "http://mydomain.com/response"
      @subscriber.subscribe_link('99', 'spreedster', return_url).should == "https://spreedly.com/your-site-name/subscribers/42/subscribe/99/spreedster?return_url=http://mydomain.com/response"
    end
    
    it "should return subscription_link for subscriber without return_url" do
      @subscriber.stub(:token).and_return("my-token")
      @subscriber.subscription_link.should == "https://spreedly.com/your-site-name/subscriber_accounts/my-token"
    end
    
    it "should return subscription_link for subscriber with return_url" do
      @subscriber.stub(:token).and_return("my-token")
      return_url = "http://mydomain.com/response"
      @subscriber.subscription_link(return_url).should == "https://spreedly.com/your-site-name/subscriber_accounts/my-token?return_url=http://mydomain.com/response"
    end
  end
end
