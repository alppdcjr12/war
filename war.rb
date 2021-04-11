require_relative "card.rb"
require_relative "deck.rb"
require_relative "player.rb"
require "byebug"

class War

    attr_accessor :players

    def initialize(num_players)
        @deck = Deck.new
        @players = []
        (1..num_players).each do |id|
            @players << Player.new(id.to_s)
        end
        deal
    end

    def total_cards_in_game
        @players.map{ |p| p.total_card_count }.inject { |n, sum| n + sum }
    end

    def deal
        @deck.shuffle
        until @deck.empty?
            @players.each do |player|
                player.down_cards << @deck.draw_card if !@deck.empty?
            end
        end
    end

    def tie_at_end_of_round?(players)
        players.all? do |p|
            !p.unplayed_cards_remaining?
        end
    end

    def is_final_tie?(players)
        if !players.empty?
            max_value = players.max_by { |p| p.up_card.point_value }.up_card.point_value
            players.all? { |p| p.up_card.point_value == max_value && !p.unplayed_cards_remaining? }
        else
            false
        end
    end
    
    def current_highest(players)
        players.select { |p| p.up_card.point_value == players.max_by { |pl| pl.up_card.point_value }.up_card.point_value }
    end
    
    def current_not_highest(players)
        players.select { |p| p.up_card.point_value != players.max_by { |pl| pl.up_card.point_value }.up_card.point_value }
    end

    def do_battle(players)
        max = players.max_by { |player| player.up_card.point_value }
        winners = @players.select { |player| player.up_card.point_value == max.up_card.point_value }
        winners
    end

    def split_winnings(winners, cards)
        winners.shuffle
        while cards.length > 0
            winners.each do |w|
                next_card = cards.pop
                w.win_battle([next_card]) if next_card != nil
            end
        end
    end

    def get_winnings(winners)
        won_cards = []
        @players.each do |player|
            if !winners.include?(player)
                won_cards += player.give_up_cards
            end
        end
        won_cards
    end

    def allocate_winnings(winners, tied_winners, staked_cards)
        if winners.length == 0
            tied_winners.each do |w|
                w.tie_battle
            end
            split_winnings(tied_winners, staked_cards)
        else
            split_winnings(winners, staked_cards)
        end
    end

    def play
        while @players.length > 1
            @players.each do |player|
                player.reset_down_cards if player.down_cards.empty?
                player.play_card
            end
            winners = do_battle(@players)
            if winners.length == 1
                won_cards = get_winnings(winners)
                winners[0].win_battle(won_cards)
            else
                staked_cards = get_winnings(winners)
                while winners.length > 1
                    winners.each do |w|
                        p w.display_player_info
                    end

                    tied_winners = []
                    losers = []

                    can_battle = winners.select { |p| p.can_battle? }
                    cannot_battle = winners.select { |p| !p.can_battle? }
                    
                    if can_battle.empty?
                        tied_winners += winners
                        winners = []
                        staked_cards += get_winnings(tied_winners)
                    else
                        can_battle.each do |p|
                            p.battle_cards
                        end
                        winners = current_highest(can_battle)
                        losers = current_not_highest(can_battle).select { |p| !p.can_battle? } + cannot_battle
                        staked_cards += get_winnings(winners)
                    end
                    @players = @players.select { |p| p if !losers.include?(p) }
                end
                allocate_winnings(winners, tied_winners, staked_cards)
            end
            @players = @players.select { |p| p if !p.lost? }
        end
        winner = @players[0]
        puts "Player #{winner.id} wins with #{winner.total_card_count}!"
    end

end

g = War.new(34)
g.play