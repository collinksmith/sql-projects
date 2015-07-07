class QuestionLike < Model
  attr_accessor :id, :user_id, :question_id

  def self.table_name
    'question_likes'
  end

  def self.find_by_id(id)
    QuestionLike.new(QuestionsDatabase.instance.execute(<<-SQL, id).first)
    SELECT
      *
    FROM
      question_likes
    WHERE
      id = ?
    SQL
  end

  def self.most_liked_questions(n)
    result = QuestionsDatabase.instance.execute(<<-SQL, n)
      SELECT
        q.*
      FROM
        questions q
      INNER JOIN
        question_likes ql ON q.id = ql.question_id
      GROUP BY
        ql.question_id
      ORDER BY
        COUNT(ql.user_id) DESC
      LIMIT
        ?
    SQL
    result.map { |question| Question.new(question) }
  end

  def self.likers_for_question_id(question_id)
    result = QuestionsDatabase.instance.execute(<<-SQL, id)
    SELECT
      u.*
    FROM
      users u
    JOIN
      question_likes ql ON u.id = ql.user_id
    WHERE
      ql.id = ?
    SQL

    result.map {|user| User.new(user)}
  end

  def self.num_likes_for_question_id(question_id)
    result_arr = QuestionsDatabase.instance.execute(<<-SQL, question_id)
    SELECT
      COUNT(user_id) count
    FROM
      question_likes
    GROUP BY
      question_id
    HAVING
      question_id = ?
    SQL
    result_arr.first['count']
  end

  def self.liked_questions_for_user_id(user_id)
    result = QuestionsDatabase.instance.execute(<<-SQL, user_id)
    SELECT
      q.*
    FROM
      questions q
    JOIN
      question_likes ql ON q.id = ql.question_id
    WHERE
      ql.user_id = ?
    SQL
    result.map {|question| Question.new(question)}
  end

  def initialize(options)
    @id =           options['id']
    @user_id =      options['user_id']
    @question_id =  options['question_id']
  end

end
