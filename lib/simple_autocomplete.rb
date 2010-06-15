module SimpleAutocomplete
  VERSION = File.read( File.join(File.dirname(__FILE__),'..','VERSION') ).strip
end

# see Readme for details
class ActionController::Base
  def self.autocomplete_for(object, method, options = {}, &block)
    options = options.dup
    define_method("autocomplete_for_#{object}_#{method}") do
      methods = options.delete(:match) || [*method]
      condition = methods.map{|m| "LOWER(#{m}) LIKE ?"} * " OR "
      values = methods.map{|m| "%#{params[:q].to_s.downcase}%"}
      conditions = [condition, *values]

      model = object.to_s.camelize.constantize
      find_options = {
        :conditions => conditions,
        :order => "#{methods.first} ASC",
        :limit => 10
        }.merge!(options)

      @items = model.scoped(find_options)

      out = if block_given?
        instance_exec @items, &block
      else
        %Q[<%= @items.map {|item| h(item.#{methods.first})}.uniq.join("\n")%>]
      end
      render :inline => out
    end
  end
end

# Store the value of the autocomplete field as association
# autocomplete_for('user','name')
# -> the auto_user_name field will be resolved to a User, using User.find_by_autocomplete_name(value)
# -> Post has autocomplete_for('user','name')
# -> User has find_by_autocomplete('name')
# add_by_autocomplete('user','name) -- for has_many() association, like on github's collaborators search
# -> Post has add_by_autocomplete('user','name) 
# -> rest works the same as autocomplete_for
# -> TODO: add tests
# see Readme for more details
class ActiveRecord::Base
  def self.autocomplete_for(model, attribute, options={})
    name = options[:name] || model.to_s.underscore
    name = name.to_s
    model = model.to_s.camelize.constantize

    # is the correct finder defined <-> warn users
    finder = "find_by_autocomplete_#{attribute}"
    unless model.respond_to? finder
      raise "#{model} does not respond to #{finder}, maybe you forgot to add auto_complete_for(:#{attribute}) to #{model}?"
    end

    #auto_user_name= "Hans"
    define_method "auto_#{name}_#{attribute}=" do |value|
      send "#{name}=", model.send(finder, value)
    end

    #auto_user_name
    define_method "auto_#{name}_#{attribute}" do
      send(name).try(:send, attribute).to_s
    end
  end

  def self.find_by_autocomplete(attr)
    metaclass = (class << self; self; end)
    metaclass.send(:define_method, "find_by_autocomplete_#{attr}") do |value|
      return if value.blank?
      self.first(:conditions => [ "LOWER(#{attr}) = ?", value.to_s.downcase ])
    end
  end
  
  def self.add_by_autocomplete(model, attribute, options={})
    name = options[:name] || model.to_s.underscore
    name = name.to_s
    model = model.to_s.camelize.constantize

    # is the correct finder defined <-> warn users
    finder = "find_by_autocomplete_#{attribute}"
    unless model.respond_to? finder
      raise "#{model} does not respond to #{finder}, maybe you forgot to add auto_complete_for(:#{attribute}) to #{model}?"
    end

    #add_user_by_autocomplete== "Hans"
    define_method "add_#{name}_by_autocomplete=" do |value|
      send(name.pluralize).send('<<', model.send(finder, value))
    end

    #just to avoid a method missing error when rendering the field
    define_method "add_#{name}_by_autocomplete" do
      #send(name).try(:send, attribute).to_s
    end
  end
end