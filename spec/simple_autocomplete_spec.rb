require File.expand_path("spec_helper", File.dirname(__FILE__))

describe UsersController do
  before do
    @c = UsersController.new
    @c.stubs(:params).returns Hash.new
    @c.stubs(:render)
  end
  
  describe 'basics' do
    it "can use long method/class names" do
      class UserAddress < ActiveRecord::Base
        set_table_name :users
      end
      UserAddress.expects(:find).with do |all,options|
        options[:conditions] == ['LOWER(full_name) LIKE ?','%hans%']
      end
      
      @c.stubs(:params).returns :q=>'Hans'
      UsersController.autocomplete_for(:user_address,:full_name)
      @c.autocomplete_for_user_address_full_name
    end
  end
  
  describe 'simple autocomplete' do
    before do
      UsersController.autocomplete_for(:user,:name)
    end
    
    it "renders the items inline" do
      @c.expects(:render).with {|hash| hash[:inline] =~ /@items.map \{|item| h(item.name)\}.uniq.join(\'\n\')/}
      @c.autocomplete_for_user_name
    end
    
    it "oders ASC bey name" do
      User.expects(:find).with do |all,options|
        options[:order] == 'name ASC'
      end
      @c.autocomplete_for_user_name
    end
    
    it "finds by name" do
      @c.stubs(:params).returns :q=>'Hans'
      User.expects(:find).with do |all,options|
        options[:conditions] == ['LOWER(name) LIKE ?','%hans%']
      end
      @c.autocomplete_for_user_name
    end
  end
  
  describe "autocomplete using blocks" do
    it "evaluates the block" do
      x=0
      UsersController.autocomplete_for(:user,:name) do |items|
        x=1
      end
      @c.autocomplete_for_user_name
      x.should == 1
    end
    
    it "passes found items to the block" do
      UsersController.autocomplete_for(:user,:name) do |items|
        items.should == ['xx']
      end
      User.expects(:find).returns ['xx']
      @c.autocomplete_for_user_name
    end
    
    it "uses block output for render" do
      UsersController.autocomplete_for(:user,:name) do |items|
        items + 'xx'
      end
      User.expects(:find).returns 'aa'
      @c.expects(:render).with {|hash| hash[:inline] == 'aaxx'}
      @c.autocomplete_for_user_name
    end
  end
end