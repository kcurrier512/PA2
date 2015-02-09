class MovieTest
  attr_accessor :test_set, :predicted_ratings, :movie_data

  #Is given number of ratings (size), the original test set, and the movie data object
  def initialize(size, test_set, movie_data)
    @movie_data = movie_data
    @test_set = test_set
    @predicted_ratings = []
    populate_predicted_ratings(size - 1)
  end

  #Goes through the given test set and predicts ratings
  def populate_predicted_ratings(size)
    (0..size).each{|index|
      guessed_rating = movie_data.predict(test_set[index][:user_id], test_set[index][:movie_id])
      predicted_ratings.push(guessed_rating)
    }
    return predicted_ratings
  end

  #Calculates mean error
  def mean
    total_difference = 0
    index = 0
    predicted_ratings.each{|rating|
      total_difference += (rating - test_set[index][:rating]).abs
    }
    return total_difference / predicted_ratings.length
  end

  #Calculates standard deviation of the error
  def stddev
    standard_deviation = 0
    mean_value = mean
    index = 0
    predicted_ratings.each{|rating|
      standard_deviation += (((rating - test_set[index][:rating]) - mean) * ((rating - test_set[index][:rating]) - mean))
    }
    return Math.sqrt(standard_deviation / predicted_ratings.length)
  end

  #Calculates the root mean square of the error
  def rms
    return Math.sqrt((mean * mean) + (stddev * stddev))
  end

  #Returns an array of the results
  def to_a
    results = Array.new
    index = 0
    predicted_ratings.each{|rating|
      single_rating = [test_set[index][:user_id], test_set[index][:movie_id], test_set[index][:rating], rating]
      results.push(single_rating)
    }
    return results
  end

end