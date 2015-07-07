class Reply
  attr_accessor :id, :body, :question_id, :parent_id, :user_id

  def self.find_by_id(id)
    Reply.new(QuestionsDatabase.instance.execute(<<-SQL, id).first
    SELECT
      *
    FROM
      replies
    WHERE
      id = ?
  SQL
  )
  end

  def self.find_by_user_id(user_id)
    result = QuestionsDatabase.instance.execute(<<-SQL, user_id)
      SELECT
        *
      FROM
        replies
      WHERE
        user_id = ?
    SQL
    result.map { |reply| Reply.new(reply) }
  end

  def self.find_by_question_id(question_id)
    result = QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT
        *
      FROM
        replies
      WHERE
        question_id = ?
    SQL
    result.map { |reply| Reply.new(reply) }
  end

  def initialize(options)
    @id =           options['id']
    @body =         options['body']
    @question_id =  options['question_id']
    @parent_id =    options['parent_id']
    @user_id =      options['user_id']
  end

  def author
    User.find_by_id(@user_id)
  end

  def question
    Question.find_by_id(@question_id)
  end

  def parent_reply
    Reply.find_by_id(@parent_id)
  end

  def child_replies
    children = QuestionsDatabase.instance.execute(<<-SQL, @id)
      SELECT
        *
      FROM
        replies
      WHERE
        parent_id = ?
    SQL

    children.map { |child| Reply.new(child) }
  end
end
