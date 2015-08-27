class User < Model
  attr_accessor :id, :fname, :lname

  def self.table_name
    'users'
  end

  def self.find_by_id(id)
    User.new(QuestionsDatabase.instance.execute(<<-SQL, id).first)
      SELECT
        *
      FROM
        users
      WHERE
        id = ?
    SQL
  end

  def self.find_by_name(fname, lname)
    result = User.new(QuestionsDatabase.instance.execute(<<-SQL, fname, lname))
      SELECT
        *
      FROM
        users
      WHERE
        fname = ? AND lname = ?
    SQL
    result.map { |user| User.new(user) }
  end

  def initialize(options)
    @id = options['id']
    @fname = options['fname']
    @lname = options['lname']
  end

  def authored_questions
    Question.find_by_author_id(@id)
  end

  def authored_replies
    Reply.find_by_user_id(@id)
  end

  def followed_questions
    QuestionFollow.followed_questions_for_user_id(@id)
  end

  def liked_questions
    QuestionLike.liked_questions_for_user_id(@id)
  end

  def average_karma
    result_arr = QuestionsDatabase.instance.execute(<<-SQL, @id)
      SELECT
        (data.num_likes / CAST(data.num_questions AS FLOAT)) karma
      FROM (
        SELECT
          COUNT(DISTINCT(q.id)) num_questions,
          COUNT(ql.question_id) num_likes
        FROM
          questions q
        LEFT OUTER JOIN
          question_likes ql ON q.id = ql.question_id
        WHERE
          q.user_id = ?
      ) data
    SQL
    result_arr.first['karma']
  end

end
