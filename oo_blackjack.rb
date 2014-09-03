class Player
	attr_accessor :name, :hand

	def initialize(name)
		@hand = Hand.new
		@name = name
	end
	
end

class Hand
	attr_accessor :cards

	def initialize
		@cards = []
	end

	def get_card(deck)
		self.cards << deck.pop
	end

	def value
		ace_counter = 0
		total_value = 0

		cards.each do |card|
			if card[0] == "Jack" || card[0] == "Queen" || card[0] == "King"
        total_value += 10
      elsif card[0] != "Ace"
        total_value += card[0].to_i
      else
        ace_counter += 1
      end
		end

		while ace_counter > 0
	    if total_value + 11 <= 21 
	      total_value += 11
	    else
	      total_value += 1
	    end
	    ace_counter -= 1 
  	end
  	total_value
	end

	def busted?
		value > 21 ? true : false		
	end

	def reset
		self.cards = []
	end
end

class Deck
	attr_accessor :cards

	SUITS = ["Hearts", "Clubs", "Diamonds", "Spades"]
	NUMBERS = ["2" , "3", "4", "5", "6", "7", "8", "9", "10", "Jack", "Queen", "King", "Ace"]
	
	def initialize
		@cards = NUMBERS.product(SUITS).shuffle
	end
end

class Game
	attr_accessor :player, :dealer, :deck

	def initialize
		system("clear")
		@deck = Deck.new
		@player = Player.new("Player_1")
		@dealer = Player.new("El macho")
	end
	
	def initial_deal
		2.times{player.hand.get_card(deck.cards)}
		2.times{dealer.hand.get_card(deck.cards)}

		blackJack_or_busted?(player.name, player.hand)
	end

	def player_turn
		dealer_plays = false
		display(dealer_plays)
		begin
			puts " "
			puts "Do you want to hit or stay? (h/s)"

			choice = gets.chomp.downcase
			if choice == "h"
				player.hand.get_card(deck.cards)
				system("clear")
				display(dealer_plays)
			end 

			if (player.hand.value >= 21) then break end
		end until choice == "s"
		blackJack_or_busted?(player.name, player.hand)
	end

	def dealer_turn
		dealer_plays = true
		while dealer.hand.value < 17 
			dealer.hand.get_card(deck.cards)
		end
		display(dealer_plays)
		blackJack_or_busted?(dealer.name, dealer.hand)
	end

	def blackJack_or_busted?(player_name, player_hand)
			if player_hand.value == 21 && player_hand.cards == 2
				puts "BlackJack!, #{player_name} won!"
				play_again?
			elsif player_hand.busted?
				puts "#{player_name} busted! and lost"
				play_again?
			end
	end

	def compare_hands(player_hand,dealer_hand)
		if dealer.hand.value == 21
			puts "The dealer kicked your ass and won"
		elsif dealer.hand.value >= player.hand.value
			puts "Mr. D is better than you. You loose!"
		else
			puts "You won!"
		end
		play_again?
	end

	def display(dealer_plays)
		system("clear")
		puts "Welcome to my awesome BlackJack Game"
		puts " "
		puts "---------#{player.name}'s hand----------"	
		puts " "
		player.hand.cards.each do |card|
			puts "#{card[0]} of #{card[1]}"
		end
		puts " "
		puts "Accumulated Score: #{player.hand.value}"
		puts " "
		puts "---------#{dealer.name}'s hand----------"
		puts " "
		if dealer_plays
			dealer.hand.cards.each do |card|
			puts "#{card[0]} of #{card[1]}"
			end
			puts " "
			puts "Accumulated Score: #{dealer.hand.value}"
		else
			puts "First card is hidden. The second card is: "
			puts " "
			puts "#{dealer.hand.cards[1][0]} of #{dealer.hand.cards[1][1]}"
		end
		puts "----------------------------------------"
	end

	def reset_hands
		player.hand.reset
		dealer.hand.reset
	end	

	def play_again?
	  begin 
	    puts " "
	    puts "Would you like to play again: (Y/N)"
	    answer = gets.chomp.capitalize

	    if answer == "Y"
	    	deck = Deck.new
	      play
	    elsif answer == "N"
	    	exit
	    end
	  end until answer == "Y" || answer == "N"
	end

	def play
		reset_hands
		initial_deal
		player_turn
		dealer_turn
		compare_hands(player.hand,dealer.hand)
	end
end

play = Game.new.play