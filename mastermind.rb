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
    @round_number = 1
    game_turn
  end
  attr_reader :board, :round_number

  def code_maker
    @board = Array.new(4)
    @board.map! { CODES.sample }
  end

  # code here isn't needed. Used for debugging
  def check_code
    puts "this is the code: #{@player2.read_code}"
  end

  def game_turn
    if @round_number == 10
      game_over
    else
      player_guess = @player1.guess_code

      @player1.save_feedback(check_answer(player_guess))
      @round_number += 1
    end
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
      print "Code is: #{code}.\n"
    end

    # used to save feedback to provide to codebreaker
    feedback = []
    feedback.push(location_match(guess, code))

    # remove the correct code & guess location so can find other matches
    code = delete_code_location_match(code, feedback.flatten)
    guess = delete_guess_location_match(guess, feedback.flatten)
    puts "delete code: #{code} and guess: #{guess}\n"

    # will give count of number of correct colours in incorrect positions
    # flattens to prevent array of arrays
    feedback.push(correct_colours(guess, code))

    print "This is the check_answer feedback #{feedback}"
    feedback
  end

  def delete_code_location_match(code, feedback)
    # deletes matches in the code where the guess was correct
    # needed to not duplicate a check for correct colour guess
    code.delete_if.with_index { |_, index| feedback.include?(index) }
  end

  def delete_guess_location_match(guess, feedback)
    # deletes matches in the guess where the guess was correct
    # needed to not duplicate a check for correct colour guess
    guess.delete_if.with_index { |_, index| feedback.include?(index) }
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

  # unsure if working correctly, untested
  def game_over
    # end of game if go to 10 rounds
    puts "You have made #{@round_number} guesses and failed. Codebreaker wins."\
    "The correct code was #{@player2.read_code}"
    new_game
  end

  # unsure if working correctly, untested
  def new_game
    puts "Hello, would you like to play a new game of Mastermind? (yes/no)?"
    answer = gets.chomp

    until %w[yes no].include?(answer)
      puts "Would you like to play a new game of Mastermind? (yes/no)?"
      answer = gets.chomp
    end

    Game.new if answer == "yes"
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
      choice = gets.chomp.to_s.strip
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
# TODO add a function that saves feedback and can provide feedback upon request
  def save_feedback(guess)
    puts "the round number is: #{@game.round_number}"
    plural = guess[0].length == 1 ? "code" : "codes"
    puts "You correctly guessed the location of #{guess[0].length} #{plural}."
    plural = guess[1] == 1 ? "code" : "codes"
    puts "You correctly guessed the colour of #{guess[1]} #{plural}.\n"
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
