require_relative "card.rb"

class Deck

    attr_reader :cards, :drawn_cards

    def initialize
        @cards = []
        @drawn_cards = []
        (2..14).each do |point_value|
            @cards << Card.new(point_value, "diamonds")
            @cards << Card.new(point_value, "spades")
            @cards << Card.new(point_value, "hearts")
            @cards << Card.new(point_value, "clubs")
        end
    end

    def shuffle
        @cards.shuffle!
    end

    def draw_card
        card = @cards[0]
        @cards.delete_at(0)
        @drawn_cards << card
        card
    end

    def empty?
        @cards.empty?
    end

end