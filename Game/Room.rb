require 'json'

class Room
    attr_accessor :contents
    attr_reader :connections
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
        puts "" #newline
    end

    def get_message(content)
        case content
        when Contents::WUMPUS
            puts TextColor.Green("You smell something terrible nearby.")
        when Contents::BATS
            puts TextColor.Blue("You hear a rustling.")
        when Contents::TRAP
            puts TextColor.Red("You feel a cold wind blowing from a nearby cavern.")
        end
    end

    def self.assignContents(player,rooms)
        emptyRoomIDs = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20]
        emptyRoomIDs.delete_at(player.room-1)
        # position the wumpus
        index = rand(0...emptyRoomIDs.count)
        id = emptyRoomIDs[rand(0...emptyRoomIDs.count)]
        rooms[id.to_s].contents = Contents::WUMPUS
        emptyRoomIDs.delete_at(index)
        player.wumpus = id
        # position the traps
        index = rand(0...emptyRoomIDs.count)
        id = emptyRoomIDs[index]
        rooms[id.to_s].contents = Contents::TRAP
        emptyRoomIDs.delete_at(index)

        index = rand(0...emptyRoomIDs.count)
        id = emptyRoomIDs[index]
        rooms[id.to_s].contents = Contents::TRAP
        emptyRoomIDs.delete_at(index)

        # position the bats
        index = rand(0...emptyRoomIDs.count)
        id = emptyRoomIDs[index]
        rooms[id.to_s].contents = Contents::BATS
        emptyRoomIDs.delete_at(index)

        index = rand(0...emptyRoomIDs.count)
        id = emptyRoomIDs[index]
        rooms[id.to_s].contents = Contents::BATS
        emptyRoomIDs.delete_at(index)
    end
end

module Contents
    NOTHING = 0
    WUMPUS = 1
    TRAP = 2
    BATS = 3
end