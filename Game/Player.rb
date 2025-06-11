require_relative '../Helpers/TextColor'
require_relative '../Helpers/Input'
require_relative 'Room'

require 'json'

class Player
    attr_accessor :wumpus
    attr_reader :room
    def initialize(rooms)
        @room = rand(1..20)
        @arrows = 5
        @connections = [],
        @rooms = rooms
        @wumpus = 0
    end

    def gameLoop()
        state = GameState::ONGOING
        while (state == GameState::ONGOING)
            puts TextColor::Yellow("--------------------------------------------------------------")
            rm = @rooms[@room.to_s]
            @connections = rm.connections

            puts TextColor::Green("You are in room ##{@room}")
            print TextColor::Blue("The tunnels lead to rooms: ")
            print TextColor::Yellow("#{rm.connections[0]} ") #could change colors of each room but, nah they will all be yellow otherwise MY EYES
            print TextColor::Yellow("#{rm.connections[1]} ")
            print TextColor::Yellow("#{rm.connections[2]}\n\n")
            
            rm.display_connections(@rooms)

            action = Input::Gets("Shoot or move (S/M)?",["s","m","shoot","move"])

            state = doAction(action);
            #resolve wumpus movement
            if state != GameState::VICTORY #the wumpus is not dead
                if rand(100) > 75 # the wumpus wakes up and moves
                    wRoom = @rooms[@wumpus.to_s]
                    newPos = wRoom.connections.sample
                    wRoom.contents = Contents::NOTHING
                    newRoom = @rooms[newPos.to_s]
                    @wumpus = newPos
                    newRoom.contents = Contents::WUMPUS
                    if (@wumpus == @room)
                        puts TextColor::Red("The wumpus wakes and attacks you!!")
                        state = GameState::EATEN
                    end
                end
            end
        end
        puts state
    end

    def doAction(action)
        if action == "s" or action == "shoot" #shoot
            path = createArrowPath()
            # resolve path
            path.each do |i|
                #check for hit
                contents = @rooms[i].contents
                if (contents == Contents::WUMPUS)
                    return GameState::VICTORY
                elsif (i.to_i == @room)
                    return GameState::HIT
                end
            end
            puts TextColor::Red("You arrow does not hit anything.")
            @arrows -= 1
            if @arrows <= 0
                return GameState::AMMO
            end
            return GameState::ONGOING #nothing happens
        else #move
            moveTo = Input::Gets("Where would you like to move to (#{@connections[0]}, #{@connections[1]}, #{@connections[2]})?",@connections)
            @room = moveTo.to_i
            
            rm = @rooms[moveTo]

            while rm.contents == Contents::BATS
                @room = rand(1..20)
                puts TextColor::Red("You encounter a giant bat!\nIt carries you to room ##{@room}!")
                rm = @rooms[@room.to_s] #check next room
            end

            case rm.contents
            when Contents::WUMPUS
                return GameState::EATEN
            when Contents::TRAP
                return GameState::TRAP
            end
            
            return GameState::ONGOING #nothing happens
        end
    end

    def createArrowPath()
        maxrooms = 20
        len = Input::Gets("How many rooms (1-5)? ",["1","2","3","4","5"]).to_i

        path = []

        (1..len).each do |i|
            #ask for room and validate it
            valid_rooms = ["1","2","3","4","5","6","7","8","9","10","11","12","13","14","15","16","17","18","19","20"]
            while true
                p = Input::Gets("Room #",valid_rooms)
                if i == 1 #first path should be in connections
                    if @connections.include?(p)
                        path.push(p)
                        break
                    else 
                        puts TextColor::Red("\nPath must start in an adjacent room.")
                    end
                else
                    last_room = path[path.length-1]
                    room_connections = @rooms[last_room].connections

                    if !room_connections.include?(p) 
                        p = room_connections.sample
                    end
                    path.push(p)
                    break
                end
            end
        end

        return path
    end

    def displayFinalMessage(state)
        case state
        when GameState::VICTORY
            puts TextColor::Green("You struck the wum")
        end
    end

    def self.displayTitle()
        file_path = File.expand_path('../logo.json', __dir__)
        data = JSON.parse(File.read(file_path))

        animation = data["animation"]
        TextColor::Clear()
        animation.each_with_index do |frame, index|
            puts TextColor::Red(frame)
            sleep(0.1)

            # Move cursor up by the number of lines in the frame (count the lines)
            line_count = frame.count("\n") + 1
            print "\e[#{line_count}A" unless index == animation.size - 1
        end
    end
end

module GameState
    ONGOING = -1
    VICTORY = 0
    EATEN = 1 #the wumpus ate you
    TRAP = 2  #oh the pitfalls of being an adventurer... I will see my self out
    AMMO = 3 #you are out of ammo
    HIT = 4 #hit by your own arrow
end