require_relative '../Helpers/TextColor'
require_relative '../Helpers/Input'
require_relative 'Room'

class Player
    attr_reader :room
    def initialize(rooms)
        @room = rand(1..20)
        @arrows = 5
        @connections = [],
        @rooms = rooms
    end

    def gameLoop()
        state = GameState::ONGOING
        while (state == GameState::ONGOING)
            #TextColor::Clear() #clears all text
            puts TextColor::Yellow("--------------------------------------------------------------")
            startTurn()
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

        end
    end

    def startTurn() #all the actions (ie. falling into pit bats etc.)

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
end

module GameState
    ONGOING = -1
    VICTORY = 0
    EATEN = 1 #the wumpus ate you
    TRAP = 2  #oh the pitfalls of being an adventurer... I will see my self out
    AMMO = 3 #you are out of ammo
    HIT = 4 #hit by your own arrow
end