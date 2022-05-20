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
    player_guess = @player1.guess_code
    check_answer(player_guess)
  end

  def check_answer(guess)
    # retrieve current answer code
    # is guess equal to code, if yes, return winner
    # loop through each index in guess, and check if same as answer, if yes same to another array
    # somehow, remove that choice from next check
    # next check each one that is not the same if it is included in answer
    # if yes move to second array
    # provide feedback from both arrays
    code = @player2.read_code
    if code == guess
      puts "WINNER!"
      return
    else
      puts "not a winner"
    end

    # used to save feedback to provide to codebreaker
    feedback = []

    feedback.push(location_match(guess, code))

    # remove the correct code guess location so can find other matches
    code.delete_at(1)
    guess.delete_at(1)

    # will give count of number of correct colours in incorrect positions
    # flattens to prevent array of arrays
    # TODO give feedback to player in readable manner
    feedback.push(correct_colours(guess, code)).flatten!

    print "This is the check_answer feedback #{feedback}"
  end

  def location_match(guess, code)
    correct_guess_index = []
    # check if same spot
    guess.zip(code).each_with_index do |pair, index|
      if pair[0] == pair[1]
        correct_guess_index.push(index) # saves index location of a match
      end
    end
    correct_guess_index
  end

  def correct_colours(guess, code)
    guess.filter { |x| code.include?(x) }.length
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
    guess
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
