class FrequencyFinder

  def initialize(timestamps, resolution=1, min_count=5)
    @timestamps = timestamps.sort.map(&:to_i)
    @resolution = resolution
    @min_count = 5
  end

  def find_frequencies(list=@timestamps)
    return [] if list.length < @min_count
    to_return = []
    # First, move the array down to a zero based list
    working_list = list.dup
    min = working_list.first
    #working_list.map! {|x| x - min}

    working_hash = {}
    working_list.each do |entry|
      working_hash[entry] ||= 0
      working_hash[entry] += 1
    end

    #puts "Starting with working hash of " + working_hash.inspect

    working_list = working_hash.keys
    first_timestamp = working_list.shift

    # Go from the first_timestamp and find the difference between it and the next timestamp. Then walk through the list
    while working_list.length > 0
      #puts "Starting working_list loop with first_timestamp of #{first_timestamp} and list of #{working_list}"
      next_timestamp = working_list.shift
      beacon_values = [first_timestamp, next_timestamp]

      hypothesized_interval = next_timestamp - first_timestamp

      #puts "Looking for interval of #{hypothesized_interval}"

      while true do
        if working_hash.has_key?(beacon_values.last + hypothesized_interval)
          beacon_values.push(beacon_values.last + hypothesized_interval)
        else
          break
        end
      end

      if beacon_values.length >= @min_count
        #puts "Found a potential beacon: #{hypothesized_interval} starting at #{beacon_values.first}"
        #puts "Removing #{beacon_values} from the working hash"
        # Remove the beacons from the working hash and break out of the while loop
        # We'll remove this one later
        beacon_values.shift
        beacon_values.each do |val|
          working_hash[val] -= 1
        end
        to_return.push(Beacon.new(hypothesized_interval, beacon_values.first, beacon_values.length))
        break
      end

    end

    working_hash[first_timestamp] -= 1

    #puts "About to run again with #{working_hash} which becomes #{hash_to_array(working_hash)}\n\n"

    to_return += find_frequencies(hash_to_array(working_hash))

    to_return.flatten
  end

  def hash_to_array(hash)
    to_return = []
    hash.keys.each do |key|
      to_return.push([key] * hash[key]) unless hash[key] < 0
    end
    to_return.flatten
  end

end

class Beacon

  attr_reader :interval, :confidence, :start_ts

  def initialize(interval, start_ts, num_beacons, confidence=1.0)
    @interval = interval
    @start_ts = start_ts
    @num_beacons = num_beacons
    @confidence = confidence
  end

  def to_s
    "Starting at #{@start_ts} beacons were observed every #{@interval} seconds #{@num_beacons} times with a confidence of #{confidence * 100}%"
  end

end

if $0 == __FILE__
  data = [
      1,
      2,
      4,
      7,
      7,
      10,
      12,
      13,
      16,
      17,
      22,
      2,
      12,
      22,
      32,
      42,
      11,
      15
  ]

  #instance = FrequencyFinder.new(data)

  #puts instance.find_frequencies.inspect
end
