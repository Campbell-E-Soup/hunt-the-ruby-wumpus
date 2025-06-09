class TextColor 

    def self.Red(text)
        color = "\e[31m"
        out = color + text + "\e[0m"
        return out
    end

    def self.Green(text)
        color = "\e[32m"
        out = color + text + "\e[0m"
        return out
    end

    def self.Blue(text)
        color = "\e[34m"
        out = color + text + "\e[0m"
        return out
    end

    def self.Cyan(text)
        color = "\e[36m"
        out = color + text + "\e[0m"
        return out
    end

    def self.Magenta(text)
        color = "\e[35m"
        out = color + text + "\e[0m"
        return out
    end

    def self.Yellow(text)
        color = "\e[33m"
        out = color + text + "\e[0m"
        return out
    end

    def self.CustomColor(text, color)
        out = color + text + "\e[0m"
        return out
    end

end