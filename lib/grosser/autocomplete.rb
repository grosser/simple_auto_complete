module Grosser
  module Autocomplete      
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
    module ControllerMethods
      def autocomplete_for(object, method, options = {})
        define_method("autocomplete_for_#{object}_#{method}") do
          find_options = { 
            :conditions => [ "LOWER(#{method}) LIKE ?", '%'+params['q'].to_s.downcase + '%' ],             :order => "#{method} ASC",
            :limit => 10 }.merge!(options)
          
          @items = object.to_s.camelize.constantize.find(:all, find_options)
          
          if block_given?
            out = yield(@items)
          else
            out = %Q[<%= @items.map {|item| h(item.#{method})}.join("\n")%>]
          end
          render :inline => out
        end
      end
    end
    
    # Store the value of the autocomplete field as record
    # autocomplete_for('user','name')
    # -> the auto_user_name field will be resolved to a User, using User.find_by_autocomplete_name(value)
    # -> Post has autocomplete_for('user','name')
    # -> User has find_by_autocomplete('name')
    module RecordMethods
      def autocomplete_for(object,method)
        name = object.to_s.underscore
        object = object.to_s.camelize.constantize
        
        #auto_user_name=
        define_method("auto_#{name}_#{method}=") do |value|
          found = object.send("find_by_autocomplete_"+method,value)
          self.send(name+'=', found)
        end
        
        #auto_user_name
        define_method("auto_#{name}_#{method}") do
          return send(name).send(method) if send(name)
          ""
        end
      end
      
      def find_by_autocomplete(attr)
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
end