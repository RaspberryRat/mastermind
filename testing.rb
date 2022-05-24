require "pry-byebug"
def numbers_to_colours(num_code)
  binding.pry
  i = 0
  colour_code = []
  num_code.length.times do
    index = num_code[i]
    x = case index
    when 1 then "red"
    when 2 then "green"
    when 3 then "blue"
    when 4 then "yellow"
    when 5 then "brown"
    when 6 then "orange"
    when 7 then "black"
    when 8 then "white"
    end
    colour_code.push(x)
    i += 1
  end
  colour_code
end

arr = [1,1,2,2]

numbers_to_colours(arr)