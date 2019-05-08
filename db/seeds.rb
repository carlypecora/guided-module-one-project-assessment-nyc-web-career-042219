require 'pry'
# ActiveRecord::Base.logger = Logger.new(STDOUT)

jess = User.find_or_create_by(first_name: "Jessica", last_name: "Lin")
jess.update(neighborhood: "Flatbush")

carly = User.find_or_create_by(first_name: "Carly", last_name: "Pecora")
carly.update(neighborhood: "Williamsburg")

another_jess = User.find_or_create_by(first_name: "Jessica", last_name: "M")

alex = User.find_or_create_by(first_name: "Alex", last_name: "G.")
zach = User.find_or_create_by(first_name: "Zach", last_name: "V.")
gabbie = User.find_or_create_by(first_name: "Gabbie", last_name: "P.")
augustus = User.find_or_create_by(first_name: "Augustus", last_name: "Kirby")
jennifer = User.find_or_create_by(first_name: "Jennifer", last_name: "Oh")
ashley = User.find_or_create_by(first_name: "Ashley", last_name: "Westcott")
yasmine = User.find_or_create_by(first_name: "Yasmine", last_name: "Hartung")
catherine = User.find_or_create_by(first_name: "Catherine", last_name: "Batsoula")
pamyk = User.find_or_create_by(first_name: "Pamyk", last_name: "Charyyeva")
christian = User.find_or_create_by(first_name: "Christian", last_name: "Duncan")
adam = User.find_or_create_by(first_name: "Adam", last_name: "Sultanov")
gavin = User.find_or_create_by(first_name: "Gavin", last_name: "O'Connor")
jason = User.find_or_create_by(first_name: "Jason", last_name: "Gomez")
jake = User.find_or_create_by(first_name: "Jake", last_name: "Lovitz")
henry = User.find_or_create_by(first_name: "Henry", last_name: "Koehler")
tim = User.find_or_create_by(first_name: "Tim", last_name: "Koar")
won = User.find_or_create_by(first_name: "Won", last_name: "Kim")
qun = User.find_or_create_by(first_name: "Qun", last_name: "Huang")

a = Train.find_or_create_by(line: "A")
j = Train.find_or_create_by(line: "J")
four = Train.find_or_create_by(line: "4")
five = Train.find_or_create_by(line: "5")

comm1 = Commute.find_or_create_by(user: jess, train: four)
comm1 = Commute.find_or_create_by(user: carly, train: j)


# binding.pry