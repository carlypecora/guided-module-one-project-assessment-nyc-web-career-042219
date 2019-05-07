class Train < ActiveRecord::Base
    has_many :users
    has_many :users, through: :commutes
end