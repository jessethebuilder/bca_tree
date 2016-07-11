def ordinalize(integer)
  return "#{integer}th" if integer.to_i > 3 && integer.to_i < 20
  i = integer.to_s[-1].to_i
  case i
  when 1
    "#{integer}st"
  when 2
    "#{integer}nd"
  when 3
    "#{integer}rd"
  else
    "#{integer}th"
  end
end
