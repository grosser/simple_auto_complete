Goals
=====
 - simple unobstrusive autocomplete
 - JS-library-independent
 - Controller and Model helpers


Install
=======
    script/plugin install git://github.com/grosser/simple_auto_complete.git
    copy javascripts/css from example folder OR use your own


Examples
========

Controller
----------
By default, `autocomplete_for` limits the results to 10 entries,
and sorts by the autocomplete field.

    class UsersController < ApplicationController
      autocomplete_for :user, :name
    end


`autocomplete_for` takes a third parameter, an options hash which is used in the find:

    autocomplete_for :user, :name, :limit => 15, :order => 'created_at DESC'
      
With a block you can generate any output you need(passed into render :inline):

    autocomplete_for :post, :title do |items|
      items.map{|item| "#{item.title} -- #{item.id}"}.join("\n")
    end
      
View
----
    <%= f.text_field :auto_user_name, :class => 'autocomplete', 'autocomplete_url'=>autocomplete_for_user_name_users_path %>

Routes
------
    map.resources :users, :collection => { :autocomplete_for_user_name => :get}

JS
--
use any library you like
(includes examples for jquery jquery.js + jquery.autocomplete.js + jquery.autocomplete.css)


    jQuery(function($){//on document ready
      //autocomplete
      $('input.autocomplete').each(function(){
        var $input = $(this);
        $input.autocomplete($input.attr('autocomplete_url'));
      });
    });

Records (Optional)
------------------
 - Controller find works independent of this find
 - Tries to find the record by using `find_by_autocomplete_xxx` on the records model
 - unfound record -> nil
 - blank string -> nil

Example for a post with autocompleted user name:

    class User
      find_by_autocomplete :name # User.find_by_autocomplete_name('Michael')
    end

    class Post
      has_one :user
      autocomplete_for(:user,:name) #auto_user_name= + auto_user_name
      OR
      autocomplete_for(:user,:name,:name=>:creator) #auto_creator_name= + auto_creator_name (creator must a an User)
    end


Author
======
Copyright (c) 2008 Michael Grosser, released under the MIT license  
Original: Copyright (c) 2007 David Heinemeier Hansson, released under the MIT license   