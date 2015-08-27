# == Schema Information
#
# Table name: actors
#
#  id          :integer      not null, primary key
#  name        :string
#
# Table name: movies
#
#  id          :integer      not null, primary key
#  title       :string
#  yr          :integer
#  score       :float
#  votes       :integer
#  director_id :integer
#
# Table name: castings
#
#  movie_id    :integer      not null, primary key
#  actor_id    :integer      not null, primary key
#  ord         :integer

require_relative './sqlzoo.rb'

def example_join
  execute(<<-SQL)
    SELECT
      *
    FROM
      movies
    JOIN
      castings ON movies.id = castings.movie_id
    JOIN
      actors ON castings.actor_id = actors.id
    WHERE
      actors.name = 'Sean Connery'
  SQL
end

def ford_films
  # List the films in which 'Harrison Ford' has appeared.
  execute(<<-SQL)
  SELECT
    title
  FROM movies m INNER JOIN castings c
  ON m.id = c.movie_id
  WHERE
    c.actor_id = (
      SELECT
        id
      FROM
        actors
      WHERE
        name = 'Harrison Ford'
    )
  SQL
end

def ford_supporting_films
  # List the films where 'Harrison Ford' has appeared - but not in the star
  # role. [Note: the ord field of casting gives the position of the actor. If
  # ord=1 then this actor is in the starring role]
  execute(<<-SQL)
  SELECT
    title
  FROM
    movies m INNER JOIN castings c
    ON m.id = c.movie_id
  WHERE
    c.actor_id = (
      SELECT
        id
      FROM
        actors
      WHERE
        name = 'Harrison Ford'
    ) AND c.ord != 1
  SQL
end

def films_and_stars_from_sixty_two
  # List the title and leading star of every 1962 film.
  execute(<<-SQL)
  SELECT
    m.title, a.name
  FROM
    (SELECT * FROM movies WHERE yr = 1962) m
    INNER JOIN castings c
      ON m.id = c.movie_id
    INNER JOIN actors a
      ON a.id = c.actor_id
  WHERE
    c.ord = 1
  SQL
end

def travoltas_busiest_years
  # Which were the busiest years for 'John Travolta'? Show the year and the
  # number of movies he made for any year in which he made at least 2 movies.
  execute(<<-SQL)
  SELECT
    yr, COUNT(*)
  FROM
    (SELECT *
    FROM actors
    WHERE name = 'John Travolta') a
    INNER JOIN castings c
      ON a.id = c.actor_id
    INNER JOIN movies m
      ON m.id = c.movie_id
  GROUP BY
    yr
  HAVING
    COUNT(*) >= 2
  SQL
end

def andrews_films_and_leads
  # List the film title and the leading actor for all of the films 'Julie
  # Andrews' played in.
  execute(<<-SQL)
  SELECT m.title, a.name
  FROM actors a
    INNER JOIN (SELECT * FROM castings WHERE castings.ord = 1) c
      ON a.id = c.actor_id
    INNER JOIN (SELECT title, movies.id FROM movies
                INNER JOIN castings ON castings.movie_id = movies.id
                INNER JOIN actors ON actors.id = castings.actor_id
                WHERE actors.name = 'Julie Andrews') m
      ON m.id = c.movie_id
  SQL
end

def prolific_actors
  # Obtain a list in alphabetical order of actors who've had at least 15
  # starring roles.
  execute(<<-SQL)
  SELECT name
  FROM actors a INNER JOIN castings c
  ON a.id = c.actor_id
  WHERE
    c.ord = 1
  GROUP BY
    a.name
  HAVING
    COUNT(*) >= 15
  ORDER BY
    a.name
  SQL
end

def films_by_cast_size
  # List the films released in the year 1978 ordered by the number of actors
  # in the cast (descending), then by title (ascending).
  execute(<<-SQL)
  SELECT
    m.title, COUNT(*)
  FROM (SELECT * FROM movies WHERE yr = 1978) m INNER JOIN castings c
  ON m.id = c.movie_id
  GROUP BY m.title
  ORDER BY 2 DESC, 1
  SQL
end

def colleagues_of_garfunkel
  # List all the people who have played alongside 'Art Garfunkel'.
  execute(<<-SQL)
  SELECT
    a.name
  FROM
    actors a INNER JOIN castings c
      ON a.id = c.actor_id
    INNER JOIN (SELECT title, movies.id
                FROM movies INNER JOIN castings
                  ON movies.id = castings.movie_id
                INNER JOIN actors
                  ON actors.id = castings.actor_id
                WHERE actors.name = 'Art Garfunkel') m
      ON m.id = c.movie_id
  WHERE a.name != 'Art Garfunkel'
  SQL
end
