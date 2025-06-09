require 'json'

class Room
    attr_reader :contents, :connections
    def initialize(connections)
        @contents = Contents::NOTHING
        @connections = connections
    end

    # @return [Hash<String, Room>] hash mapping room IDs to Room objects
    def self.load_rooms()
        # initlizes rooms and connections
        file_content = File.read('connections.json')
        data = JSON.parse(file_content)
        rooms = {}
        (1..20).each do |i|
            key = i.to_s
            room = new(data[key])
            rooms[key] = room
        end

        return rooms
    end

    def display_connections(rooms)
        shuffle = @connections.shuffle #shuffles so the order of rooms cannot be learned
        shuffle.each do |id|
            room = rooms[id]
            get_message(room.contents)
        end
    end

    def get_message(content)
        case content
        when Contents::WUMPUS
            puts TextColor.Red("You smell something terrible nearby.")
        when Contents::BATS
            puts TextColor.Green("You hear a rustling.")
        when Contents::TRAP
            puts TextColor.Red("You feel a cold wind blowing from a nearby cavern.")
        end
    end
end

module Contents
    NOTHING = 0
    WUMPUS = 1
    BATS = 2
    TRAP = 3
end