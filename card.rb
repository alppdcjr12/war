class Card

    attr_reader :point_value, :suit, :display_value

    def initialize(point_value, suit)
        @suit = suit
        @point_value = point_value
        
        if point_value == 11
            @display_value = "J"
        elsif point_value == 12
            @display_value = "Q"
        elsif point_value == 13 
            @display_value = "K"
        elsif @point_value == 14
            @display_value = "A"
        elsif (2..10).include?(point_value)
            @display_value = @point_value.to_s
        else
            puts "Go fuck yourself "
            raise ArgumentError.new
        end
    end


end