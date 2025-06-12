require_relative 'Game/Room'
require_relative 'Game/Player'
require_relative 'Helpers/Typewriter'

rooms = Room.load_rooms()
player = Player.new(rooms)
Room.assignContents(player,rooms)

Player::displayTitle

while true
    player.gameLoop()
    answer = Input::Gets("Would you like to play a again (Y/N)? ",["y","n","yes","no"])
    break unless answer == "y" or answer == "yes"
end
TextColor::Clear()
Typewriter::outln(TextColor::Red("For now the Wumpus lies in wait..."))
Typewriter::outln(TextColor::Yellow("THANKS FOR PLAYING!!"))
