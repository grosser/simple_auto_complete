require "spec/spec_helper"

class UsersController < ActionController::Base
end

describe 'Controller extensions' do
  before do
    @c = UsersController.new
    @c.stub!(:params).and_return Hash.new
    @c.stub!(:render)
  end
  
  describe 'regression' do
    it "can use long method/class names" do
      class UserAddress < ActiveRecord::Base
        set_table_name :users
      end

      UserAddress.should_receive(:scoped).with do |options|
        options[:conditions] == ['LOWER(full_name) LIKE ?','%hans%']
      end
      
      @c.stub!(:params).and_return :q=>'Hans'
      UsersController.autocomplete_for(:user_address,:full_name)
      @c.autocomplete_for_user_address_full_name
    end
  end
  
  describe 'simple autocomplete' do
    before do
      UsersController.autocomplete_for(:user,:name)
    end
    
    it "renders the items inline" do
      @c.should_receive(:render).with {|hash| hash[:inline] =~ /@items.map \{|item| h(item.name)\}.uniq.join(\'\n\')/}
      @c.autocomplete_for_user_name
    end
    
    it "orders ASC by name" do
      User.should_receive(:scoped).with(hash_including(:order => 'name ASC'))
      @c.autocomplete_for_user_name
    end
    
    it "finds by name" do
      @c.stub!(:params).and_return :q=>'Hans'
      User.should_receive(:scoped).with(hash_including(:conditions => ['LOWER(name) LIKE ?','%hans%']))
      @c.autocomplete_for_user_name
    end
  end
  
  describe "autocomplete using blocks" do
    it "evaluates the block" do
      x=0
      UsersController.autocomplete_for(:user, :name) do |items|
        x=1
      end
      @c.autocomplete_for_user_name
      x.should == 1
    end
    
    it "passes found items to the block" do
      UsersController.autocomplete_for(:user, :name) do |items|
        items.should == ['xx']
      end
      User.should_receive(:find).and_return ['xx']
      @c.autocomplete_for_user_name
    end
    
    it "uses block output for render" do
      UsersController.autocomplete_for(:user, :name) do |items|
        items + 'xx'
      end
      User.should_receive(:scoped).and_return 'aa'
      @c.should_receive(:render).with(hash_including(:inline => 'aaxx'))
      @c.autocomplete_for_user_name
    end
  end
end

describe 'Model extensions' do
  it "warns raises when a needed finder is not defined" do
    lambda{
      class XPost < ActiveRecord::Base
        set_table_name :posts
        autocomplete_for :user, :name
      end
    }.should raise_error(/User does not respond to find_by_autocomplete_name/)
  end

  describe "auto_{association}_{attribute}" do
    it "is blank when associated is not present" do
      Post.new.auto_author_name.should == ''
    end

    it "is the attribute of the associated" do
      Post.new(:author => Author.new(:name => 'xxx')).auto_author_name.should == 'xxx'
    end
  end

  describe "auto_{association}_{attribute}=" do
    before do
      Author.delete_all
      Author.create!(:name => 'Mike')
      @pete = Author.create!(:name => 'Pete')
      Author.create!(:name => '')
    end

    it "does nothing when blank is set" do
      p = Post.new(:auto_author_name => '')
      p.author.should == nil
    end

    it "does nothing when nil is net" do
      p = Post.new(:auto_author_name => nil)
      p.author.should == nil
    end

    it "finds the correct associated and sets it" do
      p = Post.new(:auto_author_name => 'Pete')
      p.author.should == @pete
    end
  end
end