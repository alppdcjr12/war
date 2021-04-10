class Player

    attr_accessor :down_cards, :up_card, :winnings, :pow_cards
    attr_reader :id

    def initialize(id)
        @id = id
        @down_cards = []
        @up_card = nil
        @winnings = []
        @pow_cards = []
    end

    def display_player_info
        if @up_card != nil
            up_card_display = @up_card.display_value
        else
            up_card_display = "none"
        end
        puts "Player #{@id} now has #{@down_cards.length} down cards, #{@up_card_display} in play, #{@winnings.length} in winnings, and #{@pow_cards.length} cards in pow."
    end

    def play_card
        @up_card = @down_cards.pop
    end

    def finished_down_cards?
        @down_cards.empty?
    end

    def has_winnings?
        @winnings.length > 0
    end

    def lost?
        self.finished_down_cards? && !self.has_winnings?
    end

    def won?
        @down_cards.length + @winnings.length == 52
    end

    def reset_down_cards
        @winnings.each do |card|
            @down_cards << card
        end
        @winnings = []
        @down_cards.shuffle
    end

    def give_up_cards
        card = @up_card
        cards = @pow_cards
        cards << card
        @up_card = nil
        @pow_cards = []
        cards
    end

    def win_battle(cards)
        @winnings += cards
        @winnings += @pow_cards
        @winnings << @up_card if @up_card != nil
        @pow_cards = []
        @up_card = nil
    end

    def tie_battle
        @winnings += @pow_cards
        @winnings << @up_card if @up_card != nil
        @pow_cards = []
        @up_card = nil
    end

    def battle_cards
        has_reset = false
        @pow_cards << @up_card
        2.times do 
            if @down_cards.length > 0
                @pow_cards << @down_cards.pop
            else
                if !has_reset
                    self.reset_down_cards
                    has_reset = true
                end
                @pow_cards << @down_cards.pop if @down_cards.length > 0
            end
        end
        if @down_cards.length > 0
            @up_card = @down_cards.pop
        else
            if !has_reset
                self.reset_down_cards
                has_reset = true
            end
            if @pow_cards.length > 0
                @up_card = @pow_cards.pop
            end
        end
    end

    def can_battle?
        @down_cards.length > 0 || @pow_cards.length > 0 || @winnings.length > 0
    end
    
    def unplayed_cards_remaining?
        @down_cards.length > 0 || @winnings.length > 0
    end

end