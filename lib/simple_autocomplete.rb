module SimpleAutocomplete
  #Example:
  #
  #  # Controller
  #  class BlogController < ApplicationController
  #    autocomplete_for :post, :title
  #  end
  #
  #  # View
  #  <%= text_field :post, title, :class => 'autocomplete', 'autocomplete_url'=>autocomplete_for_post_title_posts_path %>
  #
  #  #routes.rb
  #  map.resources :users, :collection => { :autocomplete_for_user_name => :get}
  #
  #  # Options
  #  By default, autocomplete_for limits the results to 10 entries,
  #  and sorts by the given field.
  #
  #  autocomplete_for takes a third parameter, an options hash to
  #  the find method used to search for the records:
  #
  #    autocomplete_for :post, :title, :limit => 15, :order => 'created_at DESC'
  #
  #  # Block
  #  with a block you can generate any output you need(passed into render :inline):
  #    autocomplete_for :post, :title do |items|
  #      items.map{|item| "#{item.title} -- #{item.id}"}.join("\n")
  #    end
  class ActionController::Base
    def self.autocomplete_for(object, method, options = {})
      define_method("autocomplete_for_#{object}_#{method}") do
        model = object.to_s.camelize.constantize
        find_options = {
          :conditions => [ "LOWER(#{method}) LIKE ?", '%'+params[:q].to_s.downcase + '%' ],
          :order => "#{method} ASC",
          :limit => 10
          }.merge!(options)

        @items = model.scoped(find_options)

        out = if block_given?
          yield(@items)
        else
          %Q[<%= @items.map {|item| h(item.#{method})}.uniq.join("\n")%>]
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
  class ActiveRecord::Base
    def self.autocomplete_for(model, method, options={})
      name = options[:name] || model.to_s.underscore
      name = name.to_s
      model = model.to_s.camelize.constantize

      # is the correct finder defined <-> warn users
      finder = "find_by_autocomplete_#{method}"
      unless model.respond_to? finder
        raise "#{model} does not respond to #{finder}, maybe you forgot to add auto_complete_for(:#{method}) to #{model}?"
      end

      #auto_user_name= "Hans"
      define_method("auto_#{name}_#{method}=") do |value|
        found = model.send(finder, value)
        send("#{name}=", found)
      end

      #auto_user_name
      define_method("auto_#{name}_#{method}") do
        send(name) ? send(name).send(method) : ""
      end
    end

    def self.find_by_autocomplete(attr)
      class_eval <<-end_eval
        def self.find_by_autocomplete_#{attr}(value)
          return nil if value.blank?
          self.find(
           :first,
           :conditions => [ "LOWER(#{attr}) = ?", value.to_s.downcase ]
          )
        end
      end_eval
    end
  end
end