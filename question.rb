class Question < Model
  attr_accessor :id, :title, :body, :user_id

  def self.table_name
    'questions'
  end


  def self.find_by_id(id)
    Question.new(QuestionsDatabase.instance.execute(<<-SQL, id).first)
      SELECT
        *
      FROM
        questions
      WHERE
        id = ?
    SQL
  end

  def self.find_by_author_id(id)
    result = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        questions
      WHERE
        user_id = ?
    SQL
    result.map { |question| Question.new(question) }
  end

  def self.most_followed(n)
    QuestionFollow.most_followed_questions(n)
  end

  def self.most_like(n)
    QuestionLike.most_liked_questions(n)
  end

  def initialize(options)
    @id =       options['id']
    @title =    options['title']
    @body =     options['body']
    @user_id =  options['user_id']
  end

  def author
    User.find_by_id(@user_id)
  end

  def replies
    Reply.find_by_question_id(@id)
  end

  def followers
    QuestionFollow.followers_for_question_id(@id)
  end

  def likers
    QuestionLike.likers_for_question_id(@id)
  end

  def num_likes
    QuestionLike.num_likes_for_question_id(@id)
  end

end
