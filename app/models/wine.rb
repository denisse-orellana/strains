class Wine < ApplicationRecord
    has_many :blends
    has_many :strains, through: :blends, dependent: :destroy

    has_many :comments
    has_many :oenologists, through: :comments, dependent: :destroy

    accepts_nested_attributes_for :blends, reject_if: :all_blank, allow_destroy: true

    accepts_nested_attributes_for :comments, reject_if: :all_blank, allow_destroy: true

    default_scope { order('wines.name ASC') }
end

