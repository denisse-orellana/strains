class Oenologist < ApplicationRecord
    has_many :comments
    has_many :wines, through: :comments, dependent: :destroy

    default_scope { order('oenologists.name ASC') }
end
