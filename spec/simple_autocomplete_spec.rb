require File.expand_path("spec_helper", File.dirname(__FILE__))

describe UsersController do
  describe 'simple autocomplete' do
    before do
      @c = UsersController.new
      @c.stubs(:params).returns Hash.new
      @c.stubs(:render)
      UsersController.autocomplete_for(:user,:name)
    end
    
    it "renders the items inline" do
      @c.expects(:render).with {|hash| hash[:inline] =~ /@items.map \{|item| h(item.name)\}.uniq.join(\'\n\')/}
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
    
  end
end