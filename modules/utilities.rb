def ordinalize(integer)
  return "#{integer}th" if integer.to_i > 3 || integer.to_i < 20
  i = integer.to_s[-1]
  case i
  when i == 1
    "#{integer}st"
  when i == 2
    "#{integer}nd"
  when i == 3
    "#{integer}rd"
  else
    "#{integer}th"
  end
end
