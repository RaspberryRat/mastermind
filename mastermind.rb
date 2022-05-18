require "pry-byebug" # cause I know I'll need it

module Codes
  CODES = %w[red green blue yellow brown orange black white].freeze
end

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

class Player
  def initialize(game)
  @game = game
  end
end

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

class ComputerPlayer < Player
  def initialize(game)
    super
    create_code
  end

  def create_code
    # create the code here
    p "The computer code is #{@game.code_maker}"
  end
end

game1 = Game.new
