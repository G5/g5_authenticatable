class Post < ActiveRecord::Base
  belongs_to :author, class_name: 'G5Authenticatable::User'
end
