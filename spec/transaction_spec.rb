require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
describe RSpreedly::Transaction do

  describe ".all" do
    it "should return an empty array if there are no transactions" do
      stub_request(:get, spreedly_url("/transactions.xml")).
        to_return(:body => fixture("no_transactions.xml"), :status => 200)

      RSpreedly::Transaction.all.should == []
    end

    it "should return an array of transactions if there are any to find" do
      stub_request(:get, spreedly_url("/transactions.xml")).
        to_return(:body => fixture("transactions.xml"), :status => 200)

      RSpreedly::Transaction.all.size.should == 3 # there are 3 in the fixture
      RSpreedly::Transaction.all.select{|x| x.is_a?(RSpreedly::Transaction )}.size.should == 3
    end

    it "should allow specifying the ID of the transaction to start (since_id)" do
      stub_request(:get, spreedly_url("/transactions.xml?since_id=123")).
        to_return(:body => fixture("transactions.xml"), :status => 200)

      RSpreedly::Transaction.all(:since => 123)
      WebMock.should have_requested(:get, spreedly_url("/transactions.xml?since_id=123"))
    end
  end
end