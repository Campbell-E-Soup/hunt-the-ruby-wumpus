require_relative 'Game/Room'
require_relative 'Game/Player'

rooms = Room.load_rooms()
player = Player.new(rooms)
Room.assignContents(player,rooms)

Player::displayTitle

while true
    player.gameLoop()
end
