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

    def full_name
        "#{self.first_name} #{self.last_name}"
    end

    def self.find_all_by_first_name(name)
        users = self.where(first_name: name)
        counter = 1
        users.each do |user| 
            puts "#{counter}. #{user.full_name}"
            counter += 1
        end
    end

    # def create_new_user
    # end


end
