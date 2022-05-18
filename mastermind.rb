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
  end
  attr_reader :board

  def code_maker
    @board = Array.new(4)
    @board.map! { |code| CODES.sample }
  end
end

# superclass for players
class Player
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

  def guess_code
    puts "Make your guess"
  end
end

# sets methods for the Computer
class ComputerPlayer < Player
  def initialize(game)
    super
    @current_code = create_code
  end

  def create_code
    # create the code here
    @game.code_maker
  end

  protected

  def read_code
    @current_code
  end
end

game1 = Game.new
