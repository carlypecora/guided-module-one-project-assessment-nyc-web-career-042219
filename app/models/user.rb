class User < ActiveRecord::Base
    has_many :commutes
    has_many :trains, through: :commutes
end