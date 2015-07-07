require 'singleton'
require 'sqlite3'

class QuestionsDatabase < SQLite3::Database
  include Singleton

  def initialize
    super('questions.db')
    self.results_as_hash = true
    self.type_translation = true
  end


end

class Question
  attr_accessor :id, :title, :body, :user_id

  def self.find_by_id(id)
    Question.new(QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        questions
      WHERE
        id = ?
    SQL
    )
  end

  def initialize(options)
    @id = options.first['id']
    @title = options.first['title']
    @body = options.first['body']
    @user_id = options.first['user_id']
  end
end

class User
  attr_accessor :id, :fname, :lname

  def self.find_by_id(id)
    User.new(QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        users
      WHERE
        id = ?
    SQL
    )
  end

  def initialize(options)
    @id = options.first['id']
    @fname = options.first['fname']
    @lname = options.first['lname']
  end
end

class QuestionFollow
  attr_accessor :id, :user_id, :question_id

  def self.find_by_id(id)
    QuestionFollow.new(QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        question_follows
      WHERE
        id = ?
    SQL
    )
  end

  def initialize(options)
    @id = options.first['id']
    @user_id = options.first['user_id']
    @question_id = options.first['question_id']
  end


end

class Reply
  attr_accessor :id, :body, :question_id, :parent_id, :user_id

  def self.find_by_id(id)
    Reply.new(QuestionsDatabase.instance.execute(<<-SQL, id)
    SELECT
      *
    FROM
      replies
    WHERE
      id = ?
  SQL
  )
  end

  def initialize(options)
    o = options.first
    @id =           o['id']
    @body =         o['body']
    @question_id =  o['question_id']
    @parent_id =    o['parent_id']
    @user_id =      o['user_id']
  end
end

class QuestionLike
  attr_accessor :id, :user_id, :question_id

  def self.find_by_id(id)
    QuestionLike.new(QuestionsDatabase.instance.execute(<<-SQL, id)
    SELECT
      *
    FROM
      question_likes
    WHERE
      id = ?
  SQL
  )
  end

  def initialize(options)
    o = options.first
    @id =           o['id']
    @user_id =      o['user_id']
    @question_id =  o['question_id']
  end

end

r = Reply.find_by_id(1)
ql = QuestionLike.find_by_id(1)

p r
p ql
