require "pry-byebug"
class Game
  def initialize
    @board = Array.new(4)
    @player2 = ComputerPlayer.new(self)
  end

  attr_reader :board

  def code_maker
    p board
  end
end

class ComputerPlayer
  def initialize(game)
    binding.pry
    @game = game
    puts "I am a computer"
    create_code
  end
  def create_code
    binding.pry
    @game.code_maker
  end
end

Game.new