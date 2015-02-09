#Name: Katherine Currier

require './MovieTest.rb'
require './User.rb' 

class MovieData
	attr_accessor :hash_array, :popularity_hash, :user_array

	def initialize(folder_path)
		@popularity_hash = []
		@user_array = []
		@hash_array = load_data(folder_path)
	end

	#loads data from file into an array of hashes called hash_array
	def load_data(folder_path)
		puts "Loading Data"
		file = open("#{folder_path}/u.data")
		hash_array = []
		popularity_hash.push({:movie_id => 0, :popularity => 0}) #Cannot be nil for find_pop_hash method
		file.each_line{ |line|
			line_array = line.split(' ')
			hash = {
				:user_id => line_array[0].to_i, 
				:movie_id => line_array[1].to_i, 
				:rating => line_array[2].to_f, 
			}
			hash_array.push(hash)
			load_pop(hash) #Loads that line from the file into the load_pop method
		}
		popularity_hash.delete_at(0) #deletes original dummy value
		return hash_array
	end

	#Finds the instances of a particular movie and creates an array of hashes that holds that value
	def load_pop(hash)
		if (find_pop_hash(hash[:movie_id]).nil?)
			pop_hash = {
				:movie_id => hash[:movie_id],
				:popularity => 1,
				:users_seen => [hash[:user_id]]
			}
			popularity_hash.push(pop_hash)
		else
			find_pop_hash(hash[:movie_id])[:popularity] += 1
			find_pop_hash(hash[:movie_id])[:users_seen].push(hash[:user_id])
		end
	end

	#Searches through the popularity_hash array and returns that hash
	def find_pop_hash(movie)
 		return popularity_hash.find {|hash| hash[:movie_id] == movie}
	end

	#returns the popularity of a movie
	def popularity(movie_id)
		return find_pop_hash(movie_id)[:popularity]
	end

	#prints the movie id by popularity
	def popularity_list
		popularity_hash.sort_by!{ |hash| -hash[:popularity]}
		puts "First ten movies of popularity list:"
		print_list(0, 9, popularity_hash, :movie_id)
		puts "Last ten movies of popularity list"
		print_list(1, 10, popularity_hash, :movie_id, true)
	end

	#prints a the list
	def print_list(first, last, hash, id, negation = false)
		if (negation)
			(first..last).each do |index|
				puts hash[-index][id]
			end
		else
			(first..last).each do |index|
				puts hash[index][id]
			end
		end
	end

	#Creates a similarity rating by finding the difference in the two ratings and returning a number from 1 - 5
	def similarity_rating(user1_rating, user2_rating)
		return 5 - (user1_rating - user2_rating).abs
	end
	
	#Finds the most similar users to the given user
	def most_similar(u)
		calculating_similar(u)
		user_array.sort_by!{|hash| hash[:similarity]}
		puts "Ten least similar users to user #{u}:"
		print_list(0, 9, user_array, :user_id)
		puts "Ten most similar users to user #{u}:"
		print_list(1, 10, user_array, :user_id, true)
	end

	#Creates an array of hashes for each user's similarity as compared to the given user through the similarity method
	#934
	def calculating_similar(user1_object)
		user_array.clear
		(1..934).each {|user_id|
			hash = {
				:user_id => user_id,
				:similarity => similarity_new(user1_object, user_id)
			}
			user_array.push(hash)
		}
		return user_array
	end

	#Calls rating on the user given
	def self.rating(u, m, hash_array, user1_object = nil)
		if (user1_object.nil?)
			user1_object = User.new(u, hash_array)
		end
		return user1_object.rating(m)
	end

	#Calls movie_list on the user given
	def self.movies(u, hash_array, user1_object = nil)
		if (user1_object.nil?)
			user1_object = User.new(u, hash_array)
		end
		return user1_object.movie_list
	end

	#Prints an array of users who have seen a given movie
	def viewers(m)
		puts "Array of users who have seen movie #{m}: "
		print find_pop_hash(m)[:users_seen]
	end

	#finds the intersection of movies seen and finds the similarity between them
	def similarity_new(user1_object, u2)
		sum_similarity = 0.0
		overlaping_movies = MovieData.movies(user1_object, hash_array, user1_object) & MovieData.movies(u2, hash_array)
		overlaping_movies.each {|movie|
			sum_similarity += similarity_rating(MovieData.rating(user1_object, movie, hash_array, user1_object), MovieData.rating(u2, movie, hash_array))
		}
		if(overlaping_movies.length != 0)
			return sum_similarity/overlaping_movies.length
		else
			return 1
		end
	end

	def rating(u, m)
		MovieData.rating(u, m, hash_array)
	end
 
	def movies(u)
		MovieData.movies(u, hash_array)
	end

	#Finds the most similar users to the given and finds the average rating they gave for the given movie
	def predict(u, m)
		time1 = Time.now
		average_rating = 0
		number_movies_seen = 0
		index = 0
		user1_object = User.new(u, hash_array)
		calculating_similar(user1_object)
		user_array.sort_by!{|hash| -hash[:similarity]}
		while number_movies_seen < 10
			movie_rating = MovieData.rating(user_array[index][:user_id], m, hash_array)
			if (movie_rating != 0)
				average_rating += movie_rating
				number_movies_seen += 1
			end
			index += 1
		end
		time2 = Time.now
		puts "Time taken for predict method:  #{time2 - time1}"
		return average_rating / number_movies_seen
	end

	#Creates a new MovieTest
	def run_test(k = hash_array.length - 1)
		new_movie_test = MovieTest.new(k, hash_array, self)
		puts "mean:  #{new_movie_test.mean}"
		puts "stddev: #{new_movie_test.stddev}"
		puts "rms:  #{new_movie_test.rms}"
		print new_movie_test.to_a
	end
end

movie = MovieData.new("ml-100k")
puts movie.run_test(5)