require "pry-byebug"

module Codes
  CODES = %w[red green blue yellow brown orange black white].freeze
end

module Breakables
  def save_guess(guess)
    past_guesses.push(guess)
  end

  def save_feedback(guess)
    past_feedback.push(guess)
  end

  def report_guesses
    i = 1
    role = @game.check_role == "codebreaker" ? "You" : "The computer"
    past_guesses.length.times do
      print "\n\nIn round #{i} #{role.downcase} guessed "
      past_guesses[i - 1].each { |g| print "#{g}, " }
      plural = past_feedback[i - 1][0].length == 1 ? "code" : "codes"
      puts "\n#{role} correctly guessed the location of "\
      "#{past_feedback[-1][0].length} #{plural}."
      plural = past_feedback[i - 1][1] == 1 ? "code" : "codes"
      puts "#{role} correctly guessed the colour of #{past_feedback[i - 1][1]}"\
      " #{plural}\n"
      i += 1
    end
  end

  def report_feedback(round=0) # need to find a more elegant solution
    if round == 0
      # this retrives current round guess
      guess = past_feedback[-1]
      plural = guess[0].length == 1 ? "code" : "codes"
      role = @game.check_role == "codebreaker" ? "You" : "The computer"
      puts "\n#{role} correctly guessed the location of #{guess[0].length} #{plural}."
      plural = guess[1] == 1 ? "code" : "codes"
      puts "\n#{role} correctly guessed the colour of #{guess[1]} #{plural}.\n"
    else
      i = 1
      guess.length.times do
        print "\nIn round #{i} #{role.downcase} guessed: #{guess[i - 1]}.\n"
        plural = guess[i - 1][0].length == 1 ? "code" : "codes"
        puts "#{role} correctly guessed the location of #{guess[-1][0].length}"\
        "#{plural}."
        plural = guess[i - 1][1] == 1 ? "code" : "codes"
        puts "#{role} correctly guessed the colour of #{guess[i - 1][1]}"\
        "#{plural}\n"
        i += 1
      end
    end
  end
end

# contians the game logic
class Game
  include Codes
  def initialize
    @board = Array.new(4)
    @round_number = 1
    if codemaker_or_breaker?
      @player1 = CodeMaker.new(self)
      @player2 = ComputerPlayer.new(self, "codebreaker")
      @check_role = "codemaker"
      game_turn_codemaker
    else
      @player1 = CodeBreaker.new(self)
      @player2 = ComputerPlayer.new(self, "codemaker")
      @check_role = "codebreaker"
      puts "\nYou have 10 rounds to break the code."
      game_turn_codebreaker
    end
  end
  attr_reader :board, :round_number, :check_role

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

  def game_turn_codebreaker
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

  def game_turn_codemaker
    10.times do
      if @round_number == 10
        game_over_computer
      else
        computer_guess = @player2.guess_code
        @player2.save_feedback(check_answer(computer_guess))
        @player2.evaluate_guess
        @round_number += 1

      end
    end
  end

  def check_answer(guess)
    code = board
    if code == guess
      puts "\n\n**\nWINNER!\n**\n"
      if @check_role == "codebreaker"
      return game_over_winner
      else
        return game_over_computer_wins
      end
    else
      role = @check_role == "codebreaker" ? "You" : "The computer"
      puts "\n#{role} guess is incorrect."
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

  def game_over_computer
    # end of game if computer fails to win as codebreaker
    puts "\n\nThe computer has failed to break your code after #{@round_number} rounds! You are a brilliant codemaker."
    new_game
  end

  def game_over_computer_wins
    # game over if computer wins
    puts "\n\nThe computer has broken your code after #{@round_number}. You have failed as a codemaker."
    new_game
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
  include Breakables
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
end

# sets methods for the Computer
class ComputerPlayer < Player
  include Breakables
  def initialize(game, role)
    super
    if role == "codemaker"
      @current_code = create_code
      p read_code
    else
      puts "Comptuer is the codebreaker!"
      @past_feedback = []
      @past_guesses = []
      @possible_guesses = []
      @code_as_numbers = []
      convert_code_to_numbers
      create_permutations
    end
  end

  attr_reader :past_feedback, :past_guesses, :possible_guesses, :code_as_numbers, :compare_feedback

  def create_code
    # makes array of 4 random colours from CODES
    @game.code_maker(CODES.sample(4))
  end

  def read_code
    @current_code
  end

  def guess_code
    puts "\n\nIt is round #{@game.round_number}. It is the computer's turn to guess the code.\nThe computer guesses..."
    if @game.round_number == 1
      guess = [1, 1, 1, 1]
    elsif @game.round_number == 2
      guess = @possible_guesses[0]
    else
      guess = find_new_guess
    end
    guess = numbers_to_colours(guess)
    guess.each { |x| puts "#{x}"; }
    save_guess(guess)
    guess
  end

  def create_permutations
    # generates all possible code permutations
    code_as_numbers.repeated_permutation(4) { |p| possible_guesses.push(p) }
  end

  def numbers_to_colours(num_code)
    i = 0
    colour_code = []
    num_code.length.times do
      index = num_code[i]
      colour = case index
      when 1 then "red"
      when 2 then "green"
      when 3 then "blue"
      when 4 then "yellow"
      when 5 then "brown"
      when 6 then "orange"
      when 7 then "black"
      when 8 then "white"
      end
      colour_code.push(colour)
      i += 1
    end
    colour_code
  end

  def colours_to_numbers(colour_code)
    i = 0
    num_code = []
    colour_code.length.times do
      index = colour_code[i]
      num = case index
      when "red" then 1
      when "green" then 2
      when "blue" then 3
      when "yellow" then 4
      when "brown" then 5
      when "orange" then 6
      when "black" then 7
      when "white" then 8
      end
      num_code.push(num)
      i += 1
    end
    num_code
  end

  def convert_code_to_numbers
    CODES.each_with_index { |x, ind| code_as_numbers.push(ind + 1) }
    code_as_numbers
  end

  def evaluate_guess
    round = @game.round_number
    current_guess = colours_to_numbers(past_guesses[round - 1])
    puts "This is the current guess: #{current_guess}"
    current_feedback = past_feedback[round - 1][0].length
    puts "This is the current feedback: #{current_feedback}"
    update_guesses(current_feedback, current_guess)
  end

  def update_guesses(feedback, guess)
    previous_feedback = @past_feedback[-2][0].length
    previous_guess = colour_code(@past_guesses[-2])
    to_delete = []
    if feedback == 0
      i = 0
      guess.length.times do
        @possible_guesses.map do |arr|
          if arr.include?(guess[i])
            to_delete.push(arr)
          end
        end
        i += 1
      end
    elsif @game.round_number > 1 && (feedback < previous_feedback)
      index = find_index_difference
      @possible_guesses.map do |arr|
        to_delete.push(arr) if arr[index] == current_guess[index]
      end
    elsif @game.round_number > 1 && (feedback == previous_feedback)
      index = find_index_difference
      @possible_guesses.map do |arr|
        if arr[index] == current_guess[index] || 
          arr[index] == previous_guess[index]
          to_delete.push(arr)
        end
      end
    elsif @game.round_number > 1 && (feedback == previous_feedback)
      index = find_index_difference
      @possible_guesses.map do |arr|
        unless arr[index] == current_guess[index]
          to_delete.push(arr)
        end
      end
    else
      return
    end
    unless to_delete.length.empty?
      to_delete.uniq!
      remove_guesses(to_delete)
    end
  end

  # returns index location of the number that changed between guesses
  def find_index_difference
    current_feedback = @past_feedback[-1][0].length
    previous_feedback = @past_feedback[-2][0].length
    current_guess = colours_to_numbers(@past_guesses[-1])
    previous_guess = colours_to_numbers(@past_guesses[-2])

    # difference_needed = current_feedback.to_i + 1
    diff = current_guess.map.with_index { |x, i| x == previous_guess[i] }
    diff = diff.each_index.select { |i| diff[i] }
    diff = diff.last(1)
  end

  def remove_guesses(to_delete)
   @possible_guesses - to_delete
  end
    

end

# class when human chooses codebreaker
class CodeMaker < Player
  def initialize(game)
    puts "You are the codemaker!"
    super
    @current_code = create_code
  end

  def create_code
    puts "Choose the secret code..."
    p CODES
    secret_code = []
    i = 0
    while i < 4
      new_code = gets.chomp.to_s.strip
        until CODES.any?(new_code)
          if new_code == "feedback"
            report_guesses
            new_code = gets.chomp.to_s
          else
          puts "\nYour choice: \"#{new_code}\" is not a possible code, please enter another colour.\n"
          print "Possible colours are #{CODES}\n"
          new_code = gets.chomp.to_s
        end
      end
      secret_code.push(new_code)
      i += 1
    end
    @game.code_maker(secret_code)
  end
end

Game.new
