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

    def self.create_new_user(fullname_input)
        first_name = fullname_input.split[0]
        last_name = fullname_input.split[1]
        User.create(first_name: first_name, last_name: last_name)
    end


end
