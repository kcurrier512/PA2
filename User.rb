class User
  attr_accessor :movie_ratings, :id

  def initialize(id, all_users)
    @id = id
    @movie_ratings = []
    load_movies(all_users)
  end

  #Finds all of the movies that the user has rated from the original test set
  def load_movies(all_users)
    all_users.each {|hash| 
      if(hash[:user_id] == id)
        add_movie(hash[:movie_id], hash[:rating])
      end
    }
  end

  #Adds movie to the movie_ratings hash array
  def add_movie(movie_id, rating)
    movie_ratings.push({:movie_id => movie_id, :rating => rating})
  end

  #Retuns the rating the user gave a particular movie
  def rating(m)
    found_movie = movie_ratings.find {|movie| movie[:movie_id] == m}
    if found_movie.nil?
      return 0
    else
      return found_movie[:rating]
    end
  end

  #Returns an array of all of the movies rated by the user
  def movie_list
    seen_movies = Array.new
    movie_ratings.each {|movie|
      seen_movies.push(movie[:movie_id])
    }
    return seen_movies
  end
end