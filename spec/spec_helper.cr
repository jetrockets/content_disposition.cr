require "spectator"

require "../src/*"

Spectator.configure do |config|
  config.randomize # Randomize test order.
end
