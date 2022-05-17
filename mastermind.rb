require "pry-byebug" # cause I know I'll need it

module Codes
  CODES = %w[red green blue yellow brown orange black white].freeze
end

class Game
  include Codes
  def initialize
    @board = Array.new(4)
    @player1 = HumanPlayer.new
    @player2 = ComputerPlayer.new
  end
  attr_reader :board

  def self.code_maker # shouldn't be a class method. Need to figure this out
    @board = Array.new(4) # need to get this to pull properly from initialize not re-create
    @board.map! { |code| CODES.sample }
  end
end

class Player
  def initialize
  #  @game = game
  end
end

class HumanPlayer < Player
  def initialize
    puts "Hello codebreaker, what is your name?"
    name = gets.chomp.to_s
    @name = name
  end

  def guess_code
    puts "Make your guess"
  end
end

class ComputerPlayer < Player
  def create_code
    # create the code here
    Game.code_maker # don't want this to call a class method. Need to figure out how to call instance method
  end
end

puts ComputerPlayer.new.create_code
