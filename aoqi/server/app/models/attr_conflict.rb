class AttrConflict < ActiveRecord::Base
  belongs_to :attack, class_name: "Attr"
  belongs_to :defence, class_name: "Attr"
end
