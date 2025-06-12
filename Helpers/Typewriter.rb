class Typewriter
    # Puts a a specified string to the terminal, with a typewriter animation, followed by a new line
    # @param [String] the text to display
    # @param [int] the frames per second of the animation (default 60)
    def self.outln(text, fps: 60)
        delay = 1.0 / fps
        text.each_char do |char|
            print char
            $stdout.flush
            sleep(delay)
        end
        puts
    end
    # Puts a a specified string to the terminal, with a typewriter animation
    # @param [String] the text to display
    # @param [int] the fps of the animation (default 60)
    def self.out(text, fps: 60)
        delay = 1.0 / fps
        text.each_char do |char|
            print char
            $stdout.flush
            sleep(delay)
        end
    end
end