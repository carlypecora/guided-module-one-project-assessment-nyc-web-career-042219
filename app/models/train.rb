# == Schema Information
#
# Table name: trains
#
#  id                    :integer          not null, primary key
#  line                  :string
#  station_near_flatiron :string
#

class Train < ActiveRecord::Base
    has_many :users
    has_many :users, through: :commutes
end
