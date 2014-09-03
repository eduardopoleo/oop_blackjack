class Player
  attr_accessor :name, :hand

  def initialize(name)
    @hand = Hand.new
    @name = name
  end

  def to_s
    "hey I'm #{name}"
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
  attr_accessor :players, :dealer, :deck, :no_players

  def initialize
    system("clear")
    @players = []

    begin
      puts "How many players are playing today (1-5)"
      @no_players = gets.chomp.to_i
    end until (1..5).include?(no_players)
    
    no_players.times do |player_number|
      player_name = "Player_" + (player_number + 1).to_s
      players[player_number] = Player.new(player_name)
    end

    players[no_players] = Player.new("Dealer")
    @deck = Deck.new
  end
  
  def initial_deal
    dealer_plays = true
    (no_players + 1).times do |number|
      puts number
      2.times{players[number].hand.get_card(deck.cards)}
      blackJack_or_busted?(players[number].name, players[number].hand)
    end
    display(dealer_plays)
    all_players_blackjack_or_busted?
  end

  def players_turn
    dealer_plays = false
    display(dealer_plays)

    no_players.times do |number|
      if players[number].hand.value == 21
        puts "#{players[number].name} you got BlackJack! why would you want another card?"
        next
      end

      begin
        puts " "
        puts "#{players[number].name}'s Turn"
        puts "Do you want to hit or stay? (h/s)"

        choice = gets.chomp.downcase
        if choice == "h"
          players[number].hand.get_card(deck.cards)
          system("clear")
          display(dealer_plays)
        end 
        break if players[number].hand.value >= 21 
      end until choice == "s"

      blackJack_or_busted?(players[number].name, players[number].hand)
    end
    all_players_blackjack_or_busted?
  end

  def dealer_turn
    dealer_plays = true
    display(dealer_plays)
    blackJack_or_busted?(players[no_players].name, players[no_players].hand)

    while players[no_players].hand.value < 17 
      players[no_players].hand.get_card(deck.cards)
    end

    display(dealer_plays)
    blackJack_or_busted?(players[no_players].name, players[no_players].hand)
  end

  def blackJack_or_busted?(player_name, player_hand)
    if player_hand.value == 21 && player_hand.cards.size == 2
      puts "BlackJack!, #{player_name} won!"
      play_again? if player_name == "Dealer"
    elsif player_hand.busted?
      puts "#{player_name} busted! and lost"
      play_again? if player_name == "Dealer"
    end
  end

  def all_players_blackjack_or_busted?
    if players.select{|player| player.hand.value > 21}.size == no_players
      puts "Wao these guys are a bunch of whimps!"
      play_again?
    elsif (players.select{|player| player.hand.value == 21}.size == no_players) && 
      (players.select{|player| player.hand.cards.size == 2}.size == no_players)
      puts "All Human players got BlackJack!"
      play_again?
    end
  end

  def compare_hands
    puts "Summary: "
    no_players.times do |number|
      puts " "
      if players[number].hand.value > 21
        puts "#{players[number].name} busted"
      elsif players[number].hand.value == 21 && players[number].hand.cards.size == 2
        puts "#{players[number].name} got BlackJack!"
      elsif players[number].hand.value <= players[no_players].hand.value
        puts "#{players[number].name} Mr.D beat you"
      else
        puts "#{players[number].name} You won!"
    end
  end
    play_again?
  end

  def display(dealer_plays)
    system("clear")
    puts "Welcome to my awesome BlackJack Game"

    no_players.times do |number|
      puts " "
      puts "---------#{players[number].name}'s hand----------"  
      puts " "
      players[number].hand.cards.each do |card|
        puts "#{card[0]} of #{card[1]}"
      end
      puts " "
      puts "Accumulated Score: #{players[number].hand.value}"
      puts " "
    end
    puts "---------#{players[no_players].name}'s hand----------"
    puts " "
    if dealer_plays
      players[no_players].hand.cards.each do |card|
      puts "#{card[0]} of #{card[1]}"
      end
      puts " "
      puts "Accumulated Score: #{players[no_players].hand.value}"
    else
      puts "First card is hidden. The second card is: "
      puts " "
      puts "#{players[no_players].hand.cards[1][0]} of #{players[no_players].hand.cards[1][1]}"
    end
    puts "----------------------------------------"
  end

  def reset_hands
    (no_players + 1).times do |number|
      players[number].hand.reset
    end
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
    players_turn
    dealer_turn
    compare_hands
  end
end

play = Game.new.play