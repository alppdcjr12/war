require_relative "card.rb"
require_relative "deck.rb"
require_relative "player.rb"
require "byebug"

class War

    def initialize(num_players)
        @deck = Deck.new
        @players = []
        (1..num_players).each do |id|
            @players << Player.new(id.to_s)
        end
        deal
    end

    def deal
        @deck.shuffle
        until @deck.empty?
            @players.each do |player|
                player.down_cards << @deck.draw_card if !@deck.empty?
            end
        end
    end

    def remove_player(id)
        @players.keep_if { |player| player.id != id }
    end

    def tie_at_end_of_round?(players)
        players.all? do |p|
            !p.unplayed_cards_remaining?
        end
    end

    def is_final_tie?(players)
        max_value = players.max_by { |p| p.up_card.point_value }.up_card.point_value
        players.all? { |p| p.up_card.point_value == max_value && !p.unplayed_cards_remaining? }
    end

    def play
        while true

            #####
            @players.each do |player|
                self.remove_player(player.id) if player.lost?
                player.reset_down_cards if player.down_cards.empty?
                player.play_card
                
                puts "Player #{player.id} played #{player.up_card.display_value}."
            end
            #####
            break if @players.length < 2

            # PRINT
            max = @players.max_by { |player| player.up_card.point_value }
            
            #####
            puts "The highest point value is #{max.up_card.point_value}."
            #####

            winners = @players.select { |player| player.up_card.point_value == max.up_card.point_value }

            #####
            winners_string = winners.map { |w| "#{w.id.to_s}" }.join(", ")
            puts "Winners with that max value: #{winners_string}"
            #####

            if winners.length == 1
                p "There was only one winner."
                won_cards = []
                @players.each do |player|
                    if !winners.include?(player)
                        player.give_up_cards.each do |card|
                            won_cards << card
                        end
                    end
                end
                winners[0].win_battle(won_cards)
            else
                p "There was more than one winner."
                won_cards = []
                while winners.length > 1
                    losers = []
                    winners.each do |player|
                        if !player.can_battle?
                            losers << player
                        else
                            player.battle_cards
                        end
                    end
                    winners.keep_if { |winner| !losers.include?(winner) }

                    #####
                    winners.each do |w|
                        puts "Player #{w.id} played #{w.up_card.display_value} in the war."
                    end
                    #####

                    max = winners.max_by { |player| player.up_card.point_value }

                    #####
                    puts "The highest value of these cards is #{max.up_card.point_value}."
                    #####
                    
                    winners = winners.select { |player| player.up_card.point_value == max.up_card.point_value }
                    
                    winners_string = winners.map{ |w| w.id.to_s }.join(", ")
                    #####
                    puts "Winners after this war: #{winners_string}."
                    #####

                    # divide up the winnings in the case of a tie
                    if is_final_tie?(winners)
                        puts "Final tie - winners have no more cards left with which to battle."
                        @players.each do |player|
                            if !winners.include?(player)
                                player.give_up_cards.each do |card|
                                    won_cards << card
                                end
                            else
                                player.tie_battle
                            end
                            #####
                            player.display_player_info
                            #####
                        end
                        while won_cards.length > 0
                            winners.shuffle.each do |w|
                                w.win_battle([won_cards.pop])
                            end
                        end
                        winners = []
                        break
                    elsif tie_at_end_of_round?(winners) and winners.length > 1
                        p "Tie with more cards remaining"
                        winners.each do |w|
                            w.reset_down_cards
                        end
                        #####
                        player.display_player_info
                        #####
                    elsif winners.length == 1
                        puts "There is a single winner of the round."
                        @players.each do |player|
                            if !winners.include?(player)
                                player.give_up_cards.each do |card|
                                    won_cards << card
                                end
                            end
                        end
                        winners[0].win_battle(won_cards)
                        @players.each do |player|
                            #####
                            player.display_player_info
                            #####
                        end
                    end
                end
            end
            puts

        end
        puts "Player #{@players[0].id} wins!"
    end

end

war = War.new(2)
war.play