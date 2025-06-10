require_relative 'TextColor'

class Input 

    # Get input and validates it against an array of valid answers
    # @param [String] question
    # @param [Array<String>, nil] allowed
    # @return [String]
    def self.Gets(question, allowed = nil)
        while true
            print TextColor::Blue(question + " ")
            answer = gets.chomp.strip.downcase
            if allowed.nil?
                return answer
            elsif allowed.include?(answer) # answer is valid
                return answer
            else #answer is not valid try again
                puts TextColor::Red("Did not recognize response '#{answer}'\nPlease try again.\n")
            end
            #if we are here answer was not valid and we try again
        end
    end

end