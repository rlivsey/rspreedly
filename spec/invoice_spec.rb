require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe RSpreedly::Invoice do

  describe "#create!" do

    before(:each) do
      @subscriber = RSpreedly::Subscriber.new(:customer_id => 42, :screen_name => "bob", :email => "test@example.com")
      @invoice    = RSpreedly::Invoice.new(:subscriber => @subscriber, :subscription_plan_id => 2502)
    end

    it "should return true if successful" do
      stub_request(:post, spreedly_url("/invoices.xml")).
        to_return(:body => fixture("invoice_created.xml"), :status => 201)

      @invoice.create.should be_true
    end

    it "should update the invoice if successful" do
      stub_request(:post, spreedly_url("/invoices.xml")).
        to_return(:body => fixture("invoice_created.xml"), :status => 201)

      lambda{
        @invoice.create
      }.should change(@invoice, :price).from(nil).to("$0.00")
    end

    it "should setup line items in the invoice if successful" do
      stub_request(:post, spreedly_url("/invoices.xml")).
        to_return(:body => fixture("invoice_created.xml"), :status => 201)

      @invoice.create
      @invoice.line_items.size.should == 1
      @invoice.line_items[0].should be_a(RSpreedly::LineItem)
    end

    it "should raise NotFound if the plan doesn't exist" do
      stub_request(:post, spreedly_url("/invoices.xml")).
        to_return(:body => fixture("plan_not_found.xml"), :status => 404)

      lambda{
        @invoice.create!
      }.should raise_error(RSpreedly::Error::NotFound)
    end

    it "should raise BadRequest if the invoice is invalid" do
      stub_request(:post, spreedly_url("/invoices.xml")).
        to_return(:body => fixture("invoice_invalid.xml"), :status => 422)

      lambda{
        @invoice.create!
      }.should raise_error(RSpreedly::Error::BadRequest)
    end

    it "should raise Forbidden if the plan is disabled" do
      stub_request(:post, spreedly_url("/invoices.xml")).
        to_return(:body => fixture("plan_disabled.xml"), :status => 403)

      lambda{
        @invoice.create!
      }.should raise_error(RSpreedly::Error::Forbidden)
    end
  end

  describe "#create" do

    before(:each) do
      @subscriber = RSpreedly::Subscriber.new(:customer_id => 42, :screen_name => "bob", :email => "test@example.com")
      @invoice    = RSpreedly::Invoice.new(:subscriber => @subscriber, :subscription_plan_id => 2502)
    end

    it "should return true if successful" do
      stub_request(:post, spreedly_url("/invoices.xml")).
        to_return(:body => fixture("invoice_created.xml"), :status => 201)

      @invoice.create.should be_true
    end

    it "should return nil if the plan doesn't exist" do
      stub_request(:post, spreedly_url("/invoices.xml")).
        to_return(:body => fixture("plan_not_found.xml"), :status => 404)

      @invoice.create.should be_nil
    end

    it "should return nil if the invoice is invalid" do
      stub_request(:post, spreedly_url("/invoices.xml")).
        to_return(:body => fixture("invoice_invalid.xml"), :status => 422)

      @invoice.create.should be_nil
    end

    it "should return nil if the plan is disabled" do
      stub_request(:post, spreedly_url("/invoices.xml")).
        to_return(:body => fixture("plan_disabled.xml"), :status => 403)

      @invoice.create.should be_nil
    end
  end


  describe "#pay" do

    before(:each) do
      @invoice = RSpreedly::Invoice.new(:token => "5b1f186651dd988865c6573921ec87fa4bec23b8")
      @payment = RSpreedly::PaymentMethod::CreditCard.new(:number     => "4222222222222",
                                                          :card_type  => "visa",
                                                          :verification_value => "234",
                                                          :month      => 1,
                                                          :year       => 2011,
                                                          :first_name => "Joe",
                                                          :last_name  => "Bob")
    end

    it "should return true if successful" do
      stub_request(:put, spreedly_url("/invoices/5b1f186651dd988865c6573921ec87fa4bec23b8/pay.xml")).
        to_return(:body => fixture("payment_success.xml"), :status => 200)

      @invoice.pay(@payment).should be_true
    end

    it "should return nil if not successful" do
      stub_request(:put, spreedly_url("/invoices/5b1f186651dd988865c6573921ec87fa4bec23b8/pay.xml")).
        to_return(:body => fixture("payment_not_found.xml"), :status => 404)

      @invoice.pay(@payment).should be_nil
    end

  end

  describe "#pay!" do

    before(:each) do
      @invoice = RSpreedly::Invoice.new(:token => "5b1f186651dd988865c6573921ec87fa4bec23b8")
      @payment = RSpreedly::PaymentMethod::CreditCard.new(:number     => "4222222222222",
                                                          :card_type  => "visa",
                                                          :verification_value => "234",
                                                          :month      => 1,
                                                          :year       => 2011,
                                                          :first_name => "Joe",
                                                          :last_name  => "Bob")
    end

    it "should return true if successful" do
      stub_request(:put, spreedly_url("/invoices/5b1f186651dd988865c6573921ec87fa4bec23b8/pay.xml")).
        to_return(:body => fixture("payment_success.xml"), :status => 200)

      @invoice.pay!(@payment).should be_true
    end

    it "should update the Invoice if successful" do
      stub_request(:put, spreedly_url("/invoices/5b1f186651dd988865c6573921ec87fa4bec23b8/pay.xml")).
        to_return(:body => fixture("payment_success.xml"), :status => 200)

      lambda{
        @invoice.pay!(@payment)
      }.should change(@invoice, :closed).to(true)
    end

    it "should raise NotFound if the invoice doesn't exist" do
      stub_request(:put, spreedly_url("/invoices/5b1f186651dd988865c6573921ec87fa4bec23b8/pay.xml")).
        to_return(:body => fixture("payment_not_found.xml"), :status => 404)

      lambda{
        @invoice.pay!(@payment)
      }.should raise_error(RSpreedly::Error::NotFound)
    end

    it "should raise GatewayTimeout if the payment gateway times out" do
      stub_request(:put, spreedly_url("/invoices/5b1f186651dd988865c6573921ec87fa4bec23b8/pay.xml")).
        to_return(:status => 504)

      lambda{
        @invoice.pay!(@payment)
      }.should raise_error(RSpreedly::Error::GatewayTimeout)
    end

    it "should raise BadRequest if the payment method is invalid" do
      stub_request(:put, spreedly_url("/invoices/5b1f186651dd988865c6573921ec87fa4bec23b8/pay.xml")).
        to_return(:body => fixture("payment_invalid.xml"), :status => 422)

      lambda{
        @invoice.pay!(@payment)
      }.should raise_error(RSpreedly::Error::BadRequest)
    end

      it "should raise Forbidden if the invoice is already paid" do
        stub_request(:put, spreedly_url("/invoices/5b1f186651dd988865c6573921ec87fa4bec23b8/pay.xml")).
          to_return(:body => fixture("payment_already_paid.xml"), :status => 403)

        lambda{
          @invoice.pay!(@payment)
        }.should raise_error(RSpreedly::Error::Forbidden)
      end
  end
end