require "pry-byebug" # cause I know I'll need it

class Game
  def initialize
    @board = Array.new(4)
    @player1 = HumanPlayer.new
    @player2 = ComputerPlayer.new
  end
  attr_reader :board

end

class Player
  def initialize
    @game = game
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
  end
end


