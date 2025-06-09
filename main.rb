require_relative 'Helpers/TextColor'
require_relative 'Game/Room'

rooms = Room.load_rooms

rooms["1"].display_connections(rooms)