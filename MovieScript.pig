// ---------------------------------------- -------------------------------------------------------------------------
// Problem: 
// 		- Return the number of movies an actor played in based upon a source file 
//		where each line contains an actor name, movie title, and the year the movie was made.   
//		- Return the list with the actor - movie count in descending order
// Solution:
//		- actor name A, 34
//		- actor name B, 31
// ---------------------------------------- -------------------------------------------------------------------------
movies = LOAD '/Users/chang/Documents/Software/Languages/hadoop/ucsc/pig/practice/data/imdb.tsv' USING PigStorage() AS (actor: chararray, movieTitle: chararray, year: float );

actorGroup = GROUP movies BY actor;

actorMovieCount = FOREACH actorGroup {
	uniqueMovies = DISTINCT movies.movieTitle;
	GENERATE group AS actorName, COUNT(uniqueMovies) as movieCnt;
}

actorOrderedByMovieCount = ORDER actorMovieCount BY movieCnt DESC, actorName ASC; 



// ---------------------------------------- -------------------------------------------------------------------------
// Problem:
// 		- Return the highest rated movie per year
//		- For each movie, include the actors who played in the movie
//		- The result should be ordered by the year the movie was produced
//		- There are 2 input files. 
//			* imdb-weights.tsv contains movie titles and ratings. 
//			* imdb.tsv contains movie titles, actors, and the year the movie was made.
// Solution:
//		- Bambi, 1942, {actor1, actor2}
//		- Terminator, 1991, {actorA, actorB}
// ---------------------------------------- -------------------------------------------------------------------------
ratings = LOAD '/Users/chang/Documents/Software/Languages/hadoop/ucsc/pig/practice/data/imdb-weights.tsv' USING PigStorage('\t') AS (movieTitle: chararray, year:int, weight:float);

ratingGroupByYear = group ratings by year;

// ORDER takes a relationship, here it's ratings which is the second element in the relationship ratingGroupByYear
sortByWeight = FOREACH ratingGroupByYear {
	sorted = ORDER ratings BY weight DESC;
	GENERATE group as year, sorted;
}

highestRankMoviePerYearRaw = FOREACH sortByWeight {
	highest = LIMIT sorted 1;
	GENERATE FLATTEN(highest) AS (movie:chararray, year:int, weight:float);
}

highestRankMoviePerYear = FOREACH highestRankMoviePerYearRaw GENERATE year, movie as movieTitle, weight;
highestRankMoviePerYearOrdered = ORDER highestRankMoviePerYear BY year;

movies = LOAD '/Users/chang/Documents/Software/Languages/hadoop/ucsc/pig/practice/data/imdb.tsv' USING PigStorage() AS (actor: chararray, movie: chararray, year: int );

movieTitleGroup = group movies BY movie;

// returns a bag { (group:int, actor:{}}
movieHasTheseActors = FOREACH movieTitleGroup GENERATE group as movieTitle, movies.actor;

// Join the relationships movieHasTheseActors and highestRankMoviePerYearOrdered by movieTitle
joinData = JOIN movieHasTheseActors BY $0, highestRankMoviePerYearOrdered BY $1
dr = LIMIT joinData 10;
dump dr;

STORE joinData INTO 'hwOutput.txt' USING PigStorage('*');

