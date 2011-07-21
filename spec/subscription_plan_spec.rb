require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe RSpreedly::SubscriptionPlan do

  describe ".find" do
    describe "with the symbol :all" do
      it "should pass to RSpreedly::SubscriptionPlan.all" do
        RSpreedly::SubscriptionPlan.should_receive(:all)
        RSpreedly::SubscriptionPlan.find(:all)
      end
    end

    it "should return nil with an id for a plan which doesn't exist" do
      stub_request(:get, spreedly_url("/subscription_plans.xml")).
        to_return(:body => fixture("subscription_plan_list.xml"), :status => 200)

      RSpreedly::SubscriptionPlan.find(99).should be_nil
    end

    it "should return a SubscriptionPlan with an id for an existing plan" do
      stub_request(:get, spreedly_url("/subscription_plans.xml")).
        to_return(:body => fixture("subscription_plan_list.xml"), :status => 200)

      RSpreedly::SubscriptionPlan.find(42).should be_a(RSpreedly::SubscriptionPlan)
    end
  end

  describe ".all" do
    it "should return an empty array if there are no plans" do
      stub_request(:get, spreedly_url("/subscription_plans.xml")).
        to_return(:body => fixture("no_plans.xml"), :status => 200)

      RSpreedly::SubscriptionPlan.all.should == []
    end

    it "should return an array of SubscriptionPlans if there are any to find" do
      stub_request(:get, spreedly_url("/subscription_plans.xml")).
        to_return(:body => fixture("subscription_plan_list.xml"), :status => 200)

      RSpreedly::SubscriptionPlan.all.size.should == 4 # there are 4 in the fixture
      RSpreedly::SubscriptionPlan.all.select{|x| x.is_a?(RSpreedly::SubscriptionPlan )}.size.should == 4
    end
  end
end
