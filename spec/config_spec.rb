require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe RSpreedly::Config do

  before :each do

    RSpreedly::Config.clear
    RSpreedly::Config.setup do |c|
      c[:one] = 1
      c[:two] = 2
    end

  end

  describe "logger" do

    before :each do
      Object.send(:remove_const, :RAILS_DEFAULT_LOGGER) if defined?(RAILS_DEFAULT_LOGGER)
    end

    it "should default to RAILS_DEFAULT_LOGGER if defined" do
      RAILS_DEFAULT_LOGGER = "something"
      RSpreedly::Config.reset
      RSpreedly::Config.logger.should == "something"
    end

    it "should default to a Logger if RAILS_DEFAULT_LOGGER is not defined" do
      RSpreedly::Config.reset
      RSpreedly::Config.logger.should be_a(Logger)
    end

  end

  describe "configuration" do

    it "should return the configuration hash" do
      RSpreedly::Config.configuration.should == {:one => 1, :two => 2}
    end

  end

  describe "[]" do

    it "should return the config option matching the key" do
      RSpreedly::Config[:one].should == 1
    end

    it "should return nil if the key doesn't exist" do
      RSpreedly::Config[:monkey].should be_nil
    end

  end

  describe "[]=" do

    it "should set the config option for the key" do
      lambda{
        RSpreedly::Config[:banana] = :yellow
      }.should change(RSpreedly::Config, :banana).from(nil).to(:yellow)
    end

  end

  describe "delete" do

    it "should delete the config option for the key" do
      lambda{
        RSpreedly::Config.delete(:one)
      }.should change(RSpreedly::Config, :one).from(1).to(nil)
    end

    it "should leave the config the same if the key doesn't exist" do
      lambda{
        RSpreedly::Config.delete(:test)
      }.should_not change(RSpreedly::Config, :configuration)
    end

  end

  describe "fetch" do

    it "should return the config option matching the key if it exists" do
      RSpreedly::Config.fetch(:one, 100).should == 1
    end

    it "should return the config default if the key doesn't exist" do
      RSpreedly::Config.fetch(:other, 100).should == 100
    end

  end

  describe "to_hash" do

    it "should return a hash of the configuration" do
      RSpreedly::Config.to_hash.should == {:one => 1, :two => 2}
    end

  end

  describe "setup" do

    it "should yield self" do
      RSpreedly::Config.setup do |c|
        c.should == RSpreedly::Config
      end
    end

    it "should let you set items on the configuration object as a hash" do
      lambda{
        RSpreedly::Config.setup do |c|
          c[:bananas] = 100
        end
      }.should change(RSpreedly::Config, :bananas).from(nil).to(100)
    end

    it "should let you set items on the configuration object as a method" do
      lambda{
        RSpreedly::Config.setup do |c|
          c.monkeys = 100
        end
      }.should change(RSpreedly::Config, :monkeys).from(nil).to(100)
    end

  end

  describe "calling a missing method" do

    it "should retreive the config if the method matches a key" do
      RSpreedly::Config.one.should == 1
    end

    it "should retreive nil if the method doesn't match a key" do
      RSpreedly::Config.moo.should be_nil
    end

    it "should set the value of the config item matching the method name if it's an assignment" do
      lambda{
        RSpreedly::Config.trees = 3
      }.should change(RSpreedly::Config, :trees).from(nil).to(3)
    end

  end

end
