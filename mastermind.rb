require "pry-byebug"

module Codes
  CODES = %w[red green blue yellow brown orange black white].freeze
end

# contians the game logic
class Game
  include Codes
  def initialize
    @board = Array.new(4)
    @player1 = HumanPlayer.new(self)
    @player2 = ComputerPlayer.new(self)
    game_turn
  end
  attr_reader :board

  def code_maker
    @board = Array.new(4)
    @board.map! { CODES.sample }
  end

# code here isn't needed. Just a test
  def check_code
    puts "this is the code: #{@player2.read_code}"
  end

  def game_turn
    @player1.guess_code
  end
end

# superclass for players
class Player
  include Codes
  def initialize(game)
    @game = game
  end
end

# methods for humanplayer
class HumanPlayer < Player
  def initialize(game)
    super
    puts "Hello codebreaker, what is your name?"
    name = gets.chomp.to_s
    @name = name
  end

  attr_reader :name

  def guess_code
    guess = []
    puts "#{name} it is your turn to guess"
    puts "Please enter your guess from left to right:"
    print "Your choices are: #{CODES}\n"
    4.times do
      choice = gets.chomp.to_s
      until CODES.any?(choice)
        puts "Your choice: \"#{choice}\" is not a possible guess, please enter another guess"
        print "Possible guesses are #{CODES}\n"
        choice = gets.chomp.to_s
      end
      guess.push(choice)
    end
    print "Your guess is #{guess}.\n"
  end
end

# sets methods for the Computer
class ComputerPlayer < Player
  def initialize(game)
    super
    @current_code = create_code
    p read_code
  end

  def create_code
    @game.code_maker
  end

  def read_code
    @current_code
  end
end

Game.new
