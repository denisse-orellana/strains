class Strain < ApplicationRecord
    has_many :blends
    has_many :wines, through: :blends, dependent: :destroy

    default_scope { order('strains.name ASC') }

    validates :name, presence: true, uniqueness: true, allow_blank: false, allow_nil: false
end
