# == Schema Information
#
# Table name: users
#
#  id           :integer          not null, primary key
#  first_name   :string
#  last_name    :string
#  neighborhood :string
#

class User < ActiveRecord::Base
    has_many :commutes
    has_many :trains, through: :commutes
end
