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
            up_card_display = @up_card.display_value + @up_card.display_suit
        else
            up_card_display = "none"
        end
        "Player #{@id}: down: #{@down_cards.length}, up: #{up_card_display}, winnings: #{@winnings.length}, pow: #{@pow_cards.length}."
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
        cards << card if card != nil
        @up_card = nil
        @pow_cards = []
        cards
    end

    def total_card_count
        count = @down_cards.length + @pow_cards.length + @winnings.length
        count += 1 if @up_card != nil
        count
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
        next_cards = []
        if @down_cards.length <= 3
            next_cards = @down_cards
            @down_cards = []
            reset_down_cards
        else
            next_cards = @down_cards.pop(3)
        end

        until next_cards.length == 3 || @down_cards.length == 0
            next_cards << @down_cards.pop
        end

        @pow_cards << @up_card
        @pow_cards += next_cards
        @up_card = @pow_cards.pop
    end

    def can_battle?
        @down_cards.length > 0 || @pow_cards.length > 0 || @winnings.length > 0
    end
    
    def unplayed_cards_remaining?
        @down_cards.length > 0 || @winnings.length > 0
    end

end