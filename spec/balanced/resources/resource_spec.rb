require 'spec_helper'

describe Balanced::Resource, '.uri', :vcr do
  describe "before the marketplace is configured" do
    it 'raises an exception' do
      Balanced::Marketplace.stub(:marketplace_uri) { nil }
      expect {
        Balanced::Account.uri
      }.to raise_error(Balanced::StandardError, "Balanced::Account is nested under a marketplace, which is not created or configured.")
    end
  end

  describe 'when the marketplace is configured' do
    it 'returns the resource uri corresponding to the resource name passed in' do
      Balanced::Marketplace.stub(:marketplace_uri) { '/v1/marketplaces/TEST-MPynogsPWE3xLMnLbEbuM0g' }
      Balanced::Account.uri.should == '/v1/marketplaces/TEST-MPynogsPWE3xLMnLbEbuM0g/accounts'
    end
  end
end

describe Balanced::Resource, 'loading a resource and generating methods from the response body', :vcr do
  before do
    make_marketplace
    @account = Balanced::Account.new(email: 'user@example.com', name: 'John Doe').save
  end

  it 'generates a predicate method' do
    @account.name?.should be_true
  end

  it 'generates a getter method' do
    @account.name.should == 'John Doe'
  end

  it 'generates a setter' do
    @account.name = 'Bob Bobberson'
    @account.name.should == 'Bob Bobberson'
  end
end

describe Balanced::Resource, '.construct_from_response' do
  Klass = Class.new do
    include Balanced::Resource
  end

  it 'returns an instance of the class indicated by the uri property' do
    account = Klass.construct_from_response(uri: '/v1/marketplaces/123/accounts/123')
    account.should be_instance_of Balanced::Account
  end

  describe 'a nil attribute' do
    let(:payload) do
      { uri: '/v1/marketplaces/123/accounts/234',
        foo: nil }
    end

    subject { Klass.construct_from_response(payload) }

    it 'does not set the attributes hash for a nil attribute' do
      subject.attributes.keys.should_not include 'foo'
    end

    it 'does not generate a getter method' do
      subject.methods.should_not include :foo
    end

    it 'does not generate a setter method' do
      subject.methods.should_not include :foo=
    end

    it 'does not generate a predicate method' do
      subject.methods.should_not include :foo?
    end
  end
end
