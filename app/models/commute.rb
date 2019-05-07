# == Schema Information
#
# Table name: commutes
#
#  id       :integer          not null, primary key
#  user_id  :integer
#  train_id :integer
#

class Commute < ActiveRecord::Base
    belongs_to :user
    belongs_to :train
end
