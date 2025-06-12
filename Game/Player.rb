require_relative '../Helpers/TextColor'
require_relative '../Helpers/Input'
require_relative '../Helpers/Typewriter'

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
            puts TextColor::Yellow("-----------------------------------------------------------------------")
            rm = @rooms[@room.to_s]
            @connections = rm.connections

            Typewriter::outln(TextColor::Green("You are in room ##{@room}"))
            Typewriter::out(TextColor::Cyan("The tunnels lead to rooms: "))
            Typewriter::out(TextColor::Yellow("#{rm.connections[0]} ")) #could change colors of each room but, nah they will all be yellow otherwise MY EYES
            Typewriter::out(TextColor::Yellow("#{rm.connections[1]} "))
            Typewriter::out(TextColor::Yellow("#{rm.connections[2]}\n"))
            
            rm.display_connections(@rooms)

            action = Input::Gets("Shoot or move (S/M)?",["s","m","shoot","move"])

            state = doAction(action);
            #resolve wumpus movement
            if state == GameState::SHOT #the player shot and failed to hit
                if rand(100) > 75 # the wumpus wakes up and moves
                    wRoom = @rooms[@wumpus.to_s]
                    newPos = wRoom.connections.sample
                    wRoom.contents = Contents::NOTHING
                    newRoom = @rooms[newPos.to_s]
                    @wumpus = newPos
                    newRoom.contents = Contents::WUMPUS
                    if (@wumpus == @room)
                        Typewriter::outln(TextColor::Red("The wumpus wakes and attacks you!!"))
                        state = GameState::EATEN
                    end
                end
            end
        end
        displayFinalMessage(state)
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
            Typewriter::outln(TextColor::Red("You arrow does not hit anything."))
            @arrows -= 1
            if @arrows <= 0
                return GameState::AMMO
            end
            return GameState::SHOT #failed to hit anything
        else #move
            moveTo = Input::Gets("Where would you like to move to (#{@connections[0]}, #{@connections[1]}, #{@connections[2]})?",@connections)
            @room = moveTo.to_i
            
            rm = @rooms[moveTo]

            while rm.contents == Contents::BATS
                @room = rand(1..20)
                Typewriter::outln(TextColor::Red("You encounter a giant bat!\nIt carries you to room ##{@room}!"))
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
                        Typewriter::outln(TextColor::Red("\nPath must start in an adjacent room."))
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
            Typewriter::outln(TextColor::Red("*** THWACK! ***"),fps: 30)
            Typewriter::outln(TextColor::Green("Your arrow flies true and strikes the #{TextColor::Red("WUMPUS!")}"))
            Typewriter::outln(TextColor::Green("The beast lets out a final, gurgling roar and collapses."))
            Typewriter::outln(TextColor::Green("YOU WIN! The #{TextColor::Red("Wumpus")}" + TextColor::Green(" is no more... for now")))
        when GameState::AMMO
            Typewriter::outln(TextColor::Red("*** CLICK!! ***"),fps: 30)
            Typewriter::outln(TextColor::Red("Your last arrow clatters uselessly to the cavern floor"))
            Typewriter::outln(TextColor::Red("You are out of ammo... and the Wumpus still lives"))
            Typewriter::outln(TextColor::Red("You were the hunter. Now you're the hunted"))
        when GameState::HIT
            Typewriter::outln(TextColor::Red("*** THWACK! ***"),fps: 30)
            Typewriter::outln(TextColor::Red("Your arrow loops through the tunnels... and finds you"))
            Typewriter::outln(TextColor::Red("You shot yourself"))
            Typewriter::outln(TextColor::Red("The Wumpus is impressed. Briefly. Then it eats you"))
        when GameState::TRAP
            Typewriter::outln(TextColor::Red("*** CRACK!! ***"),fps: 30)
            Typewriter::outln(TextColor::Red("The ground gives way beneath you"))
            Typewriter::outln(TextColor::Red("Cold air rushes past as you fall—"))
            Typewriter::outln(TextColor::Red("and fall—  and fall..."))
        when GameState::TRAP
            Typewriter::outln(TextColor::Red("*** GULP!!! ***"),fps: 30)
            Typewriter::outln(TextColor::Red("The Wumpus lunges with terrifying speed"))
            Typewriter::outln(TextColor::Red("You barely have time to scream before everything goes dark"))
            Typewriter::outln(TextColor::Red("You have been eaten"))
        else
            Typewriter::outln(TextColor::Red("*** HOW!!!! ***"),fps: 30)
            Typewriter::outln(TextColor::Yellow("You should not be seeing this..."))
            Typewriter::outln(TextColor::Yellow("Honestly this is the real victory"))
            Typewriter::outln(TextColor::Yellow("Something broke, but hey, my bad code is your gain!"))
        end
    end

    def self.displayTitle()
        file_path = File.expand_path('../logo.json', __dir__)
        data = JSON.parse(File.read(file_path))

        animation = data["animation"]
        TextColor::Clear()
        fps = 1.0/14
        animation.each_with_index do |frame, index|
            puts TextColor::Red(frame)
            sleep(fps)

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
    SHOT = 5 #shot the arrow did not hit anything, chance for wumpus to wake
end