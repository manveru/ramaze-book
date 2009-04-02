require 'open-uri'

100_000.times do
  open('http://localhost:7000/')
end
