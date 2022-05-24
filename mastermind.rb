require "pry-byebug"

module Codes
  CODES = %w[red green blue yellow brown orange black white].freeze
end

# contians the game logic
class Game
  include Codes
  def initialize
    @board = Array.new(4)
    if codemaker_or_breaker?
      @player1 = CodeMaker.new(self)
      @player2 = ComputerPlayer.new(self, "codebreaker")
    else
      @player1 = CodeBreaker.new(self)
      @player2 = ComputerPlayer.new(self, "codemaker")
    end
    puts "\nYou have 10 rounds to break the code."
    @round_number = 1
    game_turn
  end
  attr_reader :board, :round_number

  def codemaker_or_breaker?
    puts "\nDo you want to be the CodeMaker or the CodeBreaker?"
    answer = gets.chomp.strip.downcase

    until %w[codemaker codebreaker].include?(answer)
      puts "You have to choose a role...\n"
      puts "\nDo you want to be the CodeMaker or the CodeBreaker?"
      answer = gets.chomp
    end
    answer == "codemaker" ? true : false
  end

  def code_maker(colour_code)
    @board = colour_code
  end

  # code here isn't needed. Used for debugging
  def check_code
    puts "this is the code: #{@player2.read_code}"
  end

  def game_turn
    10.times do
      if @round_number == 10
        game_over
      else
        player_guess = @player1.guess_code
        @player1.save_feedback(check_answer(player_guess))
        @player1.report_feedback
        @round_number += 1
      end
    end
  end

  def check_answer(guess)
    code = @player2.read_code
    if code == guess
      puts "\n\n**\nWINNER!\n**\n"
      return game_over_winner
    else
      puts "\nYour guess is incorrect."
    end

    # used to save feedback to provide to codebreaker
    feedback = []
    feedback.push(location_match(guess, code))

    # remove the correct code & guess location so can find other matches
    code = delete_code_location_match(code, feedback.flatten)
    guess = delete_guess_location_match(guess, feedback.flatten)

    # will give count of number of correct colours in incorrect positions
    # flattens to prevent array of arrays
    feedback.push(correct_colours(guess, code))
    feedback
  end

  def delete_code_location_match(code, feedback)
    # deletes matches in the code where the guess was correct
    # needed to not duplicate a check for correct colour guess
    not_guessed_code = []
    code.each_with_index do |item, index|
      not_guessed_code.push(item) unless feedback.include?(index)
    end
    not_guessed_code
  end

  def delete_guess_location_match(guess, feedback)
    # deletes matches in the guess where the guess was correct
    # needed to not duplicate a check for correct colour guess
    incorrect_match_guesses = []
    guess.each_with_index do |item, index|
      incorrect_match_guesses.push(item) unless feedback.include?(index)
    end
    incorrect_match_guesses
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

  def game_over
    # end of game if go to 10 rounds
    puts "\n\nYou have made #{@round_number} guesses and failed. Codemaker "\
    "wins.\n The correct code was #{@player2.read_code}"
    new_game
  end

  def game_over_winner
    # end of game if codebreked guesses code
    puts "\n\nYou have made #{@round_number} guesses and won! Codebreaker wins"\
    ". \nThe correct code was #{@player2.read_code}"
    new_game
  end

  def new_game
    puts "\n\nHello, would you like to play a new game of Mastermind? (yes/no)?"
    answer = gets.chomp

    until %w[yes no].include?(answer)
      puts "\nWould you like to play a new game of Mastermind? (yes/no)?"
      answer = gets.chomp
    end

    answer == "yes" ? Game.new : exit
  end
end

# superclass for players
class Player
  include Codes
  def initialize(game, role = nil)
    @game = game
  end
end

# methods for humanplayer chooses codebreaker
class CodeBreaker < Player
  def initialize(game)
    super
    puts "\nHello codebreaker, what is your name?"
    name = gets.chomp.to_s
    @name = name
    @past_feedback = []
    @past_guesses = []
  end

  attr_reader :name, :past_feedback, :past_guesses

  def guess_code
    guess = []
    puts "\n\n#{name}, it is round ##{@game.round_number}. It is your turn to guess."
    print "\nYour choices are: #{CODES}\n"
    puts "\nPlease enter your guess from left to right:"
    i = 0
    while i < 4
      choice = gets.chomp.to_s.strip
        until CODES.any?(choice)
          if choice == "feedback"
            report_guesses
            choice = gets.chomp.to_s
          else
          puts "\nYour choice: \"#{choice}\" is not a possible guess, please enter another guess.\n"
          print "Possible guesses are #{CODES}\n"
          choice = gets.chomp.to_s
        end
      end
      guess.push(choice)
      i += 1
    end
    print "\n\nYou guessed: #{guess}.\n"
    save_guess(guess)
    guess
  end

  def save_guess(guess)
    past_guesses.push(guess)
  end

  def report_guesses
    i = 1
    past_guesses.length.times do
      print "\n\nIn round #{i} you guessed "
      past_guesses[i - 1].each { |g| print "#{g}, "}
      plural = past_feedback[i - 1][0].length == 1 ? "code" : "codes"
      puts "\nYou correctly guessed the location of "\
      "#{past_feedback[-1][0].length} #{plural}."
      plural = past_feedback[i-1][1] == 1 ? "code" : "codes"
      puts "You correctly guessed the colour of #{past_feedback[i - 1][1]}"\
      " #{plural}\n"
      i += 1
    end
  end

  def save_feedback(guess)
    past_feedback.push(guess)
  end

  def report_feedback(round=0) # need to find a more elegant solution
    if round == 0
      # this retrives current round guess
      guess = past_feedback[-1]
      plural = guess[0].length == 1 ? "code" : "codes"
      puts "\nYou correctly guessed the location of #{guess[0].length} #{plural}."
      plural = guess[1] == 1 ? "code" : "codes"
      puts "\nYou correctly guessed the colour of #{guess[1]} #{plural}.\n"
    else
      i = 1
      guess.length.times do
        print "\nIn round #{i} you guessed: #{guess[i - 1]}.\n"
        plural = guess[i -1][0].length == 1 ? "code" : "codes"
        puts "You correctly guessed the location of #{guess[-1][0].length}"\
        "#{plural}."
        plural = guess[i-1][1] == 1 ? "code" : "codes"
        puts "You correctly guessed the colour of #{guess[i - 1][1]}"\
        "#{plural}\n"
        i += 1
      end
    end
  end
end

# sets methods for the Computer
class ComputerPlayer < Player
  def initialize(game, role)
    super
    if role == "codemaker"
      @current_code = create_code
      p read_code
    else
      puts "Comptuer is the codebreaker!"
    end
  end

  def create_code
    # makes array of 4 random colours from CODES
    @game.code_maker(CODES.sample(4))
  end

  def read_code
    @current_code
  end
end

# class when human chooses codebreaker
class CodeMaker < Player
  puts "You are the codemaker!"
  def initialize
    super
    
  end
end

Game.new
