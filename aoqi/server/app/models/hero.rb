class Hero < ActiveRecord::Base
  belongs_to :type
  belongs_to :attr
end
