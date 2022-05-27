require "pry-byebug"

module Codes
  CODES = %w[red green blue yellow brown orange].freeze
end

# Used for methods shared between codebreakers
module Breakables
  def save_guess(guess)
    past_guesses.push(guess)
  end

  def save_feedback(guess)
    past_feedback.push(guess)
  end

  # This prints out all guesses for player review
  def report_guesses
    i = 1
    role = @game.check_role == "codebreaker" ? "You" : "The computer"
    past_guesses.length.times do
      print "\n\nIn round #{i} #{role.downcase} guessed "
      past_guesses[i - 1].each { |g| print "#{g}, " }
      plural = past_feedback[i - 1][0].length == 1 ? "code" : "codes"
      puts "\n#{role} correctly guessed the location of "\
      "#{past_feedback[i - 1][0].length} #{plural}."
      plural = past_feedback[i - 1][1] == 1 ? "code" : "codes"
      puts "#{role} correctly guessed the colour of #{past_feedback[i - 1][1]}"\
      " #{plural}\n"
      i += 1
    end
  end

  # This prints out all feedback for player review
  def report_feedback(round = 0)
    if round.zero?
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
    @round_number = 0
    if codemaker_or_breaker?
      @player1 = CodeMaker.new(self)
      @player2 = ComputerPlayer.new(self, "codebreaker")
      @check_role = "codemaker"
      game_turn_codemaker
    else
      @player1 = CodeBreaker.new(self)
      @player2 = ComputerPlayer.new(self, "codemaker")
      @check_role = "codebreaker"
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

  private

  def game_turn_codebreaker
    until @round_number == 10
      puts "\nYou have 10 rounds to break the code."
      @round_number += 1
      player_guess = @player1.guess_code
      @player1.save_feedback(check_answer(player_guess))
      @player1.report_feedback
    end
    game_over
  end

  def game_turn_codemaker
    until @round_number == 10
      @round_number += 1
      computer_guess = @player2.guess_code
      @player2.save_feedback(check_answer(computer_guess))
      @player2.evaluate_guess
    end
    game_over_computer
  end

  protected

  def check_answer(guess)
    code = board
    if code == guess
      puts "\n\n**\nWINNER!\n**\n"
      return game_over_winner if @check_role == "codebreaker"

      return game_over_computer_wins
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

  private

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
    i = 0
    correct_colour = 0
    guess.length.times do
      if code.include?(guess[i])
        correct_colour += 1
        code.delete_at(code.index(guess[i]))
      end
      i += 1
    end
    correct_colour
  end

  def game_over
    # end of game if go to 10 rounds
    puts "\n\nYou have made #{@round_number} guesses and failed. Codemaker "\
    "wins.\n The correct code was #{@board}"
    new_game
  end

  def game_over_winner
    # end of game if codebreked guesses code
    puts "\n\nYou have made #{@round_number} guesses and won! Codebreaker wins"\
    ". \nThe correct code was #{@board}"
    new_game
  end

  def game_over_computer
    # end of game if computer fails to win as codebreaker
    puts "\n\nThe computer has failed to break your code after #{@round_number} rounds! You are a brilliant codemaker."
    new_game
  end

  def game_over_computer_wins
    # game over if computer wins
    puts "\n\nThe computer has broken your code after #{@round_number} rounds. You have failed as a codemaker."
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
    puts 'Type "feedback" to see previous guesses' if @game.round_number > 1
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
      # this will print the code for debugging
      # p read_code
    else
      puts "Comptuer is the codebreaker!"
      @past_feedback = []
      @past_guesses = []
      @possible_guesses = []
      @code_as_numbers = []
      @skip = 0
      convert_code_to_numbers
      create_permutations
    end
  end

  attr_reader :past_feedback, :past_guesses, :possible_guesses, :code_as_numbers, :compare_feedback

  private

  def create_code
    # makes array of 4 random colours from CODES
    @game.code_maker(CODES.sample(4))
  end

  def read_code
    @current_code
  end

  public

  # determines what code the computer will guess
  def guess_code
    round = @game.round_number
    puts "\n\nIt is round #{round}. It is the computer's turn to guess the code.\nThe computer guesses..."
    current_feedback = @past_feedback[-1][0].length if round > 1
    if round == 1
      guess = [1, 1, 2, 2]
    elsif round == 2 && current_feedback < 3
      guess = [3, 3, 4, 4]
    elsif round == 3 && current_feedback < 3
      guess = [5, 5, 6, 6]
    else
      guess = @possible_guesses.sort[0]
    end
    guess = numbers_to_colours(guess)
    guess.each { |x| puts "#{x}"; sleep(0.2) }
    save_guess(guess)
    guess
  end

  private

  # generates all possible code permutations
  def create_permutations
    code_as_numbers.repeated_permutation(4) { |p| possible_guesses.push(p) }
  end

  # computer uses numbers to represent colours, converts to colours
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

  # computer uses numbers to represent colours, converts to numbers
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

  # used to generate code list from CODES constant
  def convert_code_to_numbers
    CODES.each_with_index { |_, ind| code_as_numbers.push(ind + 1) }
    code_as_numbers
  end

  public

  # evaluates the guess and removes possible guesses that will be wrong
  def evaluate_guess
    round = @game.round_number
    current_guess = colours_to_numbers(past_guesses[round - 1])
    puts "This is the current guess: #{current_guess}"
    current_feedback = past_feedback[round - 1][0].length
    current_colour_feedback = past_feedback[round - 1][1]
    puts "This is the current feedback: #{current_feedback}"
    puts "This is current colour feedback : #{current_colour_feedback}"
    update_guesses(current_feedback, current_guess)
  end

  private

  def update_guesses(feedback, guess)
    round = @game.round_number
    to_delete = []
    to_keep = []
    to_delete.push(guess)
    feedback_w_colour = feedback + @past_feedback[round - 1][1]
    lock_in_guesses(guess) if feedback.positive?
    guess_combination_check(feedback_w_colour, guess) if feedback_w_colour > 0

    if feedback_w_colour.positive? && feedback.zero?
      i = 0
      guess.length.times do
        @possible_guesses.map do |arr|
          j = 0
          arr.length.times do
            to_delete.push(arr) if arr[j] == guess[j]
            j += 1
          end
        end
        i += 1
      end
    end
    if feedback_w_colour.zero?
      i = 0
      guess.length.times do
        @possible_guesses.map do |arr|
          to_delete.push(arr) if arr.include?(guess[i])
        end
        i += 1
      end
    elsif round > 1
      previous_feedback = @past_feedback[-2][0].length
      previous_guess = colours_to_numbers(@past_guesses[-2])
      index = find_index_difference
      if round > 1 && (feedback < previous_feedback)
        if find_index_difference.length < 3
          index.length.times do
            index1 = index.pop
            @possible_guesses.map do |arr|
              to_keep.push(arr) if arr[index1] == previous_guess[index1]
            end
          end
        end
      elsif round > 1 && (feedback == previous_feedback)
        reduce_guesses if feedback == 3
        if find_index_difference.length == 1
          index = index.pop
          @possible_guesses.map do |arr|
            unless arr[index] == guess[index] ||
                arr[index] == previous_guess[index]
              to_keep.push(arr)
            end
          end
        end
      elsif round > 1 && (feedback > previous_feedback)
        if find_index_difference.length == 1
          index = index.pop
          @possible_guesses.map do |arr|
            to_keep.push(arr) if arr[index] == guess[index]
          end
        end
      end
    end
    @possible_guesses = to_keep unless to_keep.empty?
    return if to_delete.empty?

    to_delete.uniq!
    remove_guesses(to_delete)
  end

  def reduce_guesses
    guess = colours_to_numbers(@past_guesses[-1])
    index = find_index_difference
    return unless index.length == 1
    index = index.pop
    array = [0, 1, 2, 3]
    array.delete_at(index)
    to_delete = []
    i = 0
    array.length.times do
      @possible_guesses.map do |arr|
        to_delete.push(arr) unless arr[array[i]] == guess[array[i]]
      end
      i += 1
    end
    remove_guesses(to_delete.uniq)
  end

  def lock_in_guesses(guess)
    i = 0
    to_keep = []
    guess.length.times do
      @possible_guesses.map do |arr|
        to_keep.push(arr) if arr[i] == guess[i]
      end
      i += 1
    end
    @possible_guesses = to_keep.uniq
  end

  # takes all possible combinations of guess and feedback and updates possible_guesses
  def guess_combination_check(feedback, guess)
    i = 0
    correct_guesses = []
    to_keep = []
    guess.permutation(feedback) { |g| correct_guesses.push(g) }
    correct_guesses.uniq!
    correct_guesses.length.times do
      @possible_guesses.map do |arr|
        arr.combination(feedback) do |n|
          to_keep.push(arr) if n == correct_guesses[i]
        end
      end
      i += 1
    end
    @possible_guesses = to_keep.uniq
  end

  # returns index location of the number that changed between guesses
  def find_index_difference
    current_guess = colours_to_numbers(@past_guesses[-1])
    previous_guess = colours_to_numbers(@past_guesses[-2])
    diff = current_guess.map.with_index { |x, i| x == previous_guess[i] }
    diff = diff.each_index.select { |i| !diff[i] }
    diff = diff.last(1) if diff.length == 1
    diff
  end

  def remove_guesses(to_delete)
    @possible_guesses -= to_delete
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
