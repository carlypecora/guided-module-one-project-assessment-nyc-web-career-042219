class Commute < ActiveRecord::Base
    belongs_to :user
    belongs_to :train
end