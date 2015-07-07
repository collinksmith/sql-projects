class QuestionFollow < Model
  attr_accessor :id, :user_id, :question_id

  def self.table_name
    "question_follows"
  end

  def self.most_followed_questions(n)
    result = QuestionsDatabase.instance.execute(<<-SQL, n)
      SELECT
        q.*
      FROM
        questions q INNER JOIN #{table_name} qf
        ON q.id = qf.question_id
      GROUP BY
        qf.question_id
      ORDER BY
        COUNT(qf.user_id) DESC
      LIMIT
        ?
    SQL

    result.map { |question| Question.new(question) }
  end

  def self.find_by_id(id)
    QuestionFollow.new(QuestionsDatabase.instance.execute(<<-SQL, id).first)
      SELECT
        *
      FROM
        question_follows
      WHERE
        id = ?
    SQL
  end

  def self.followers_for_question_id(question_id)
    result = QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT
        u.*
      FROM
        users u
      JOIN
        question_follows qf ON qf.user_id = u.id
      WHERE
        qf.question_id = ?
    SQL
    result.map { |user| User.new(user) }
  end

  def self.followed_questions_for_user_id(user_id)
    result = QuestionsDatabase.instance.execute(<<-SQL, user_id)
      SELECT
        q.*
      FROM
        question_follows qf
      JOIN
        questions q ON qf.question_id = q.id
      WHERE
        qf.user_id = ?
    SQL
    result.map { |question| Question.new(question) }
  end

  def initialize(options)
    @id = options['id']
    @user_id = options['user_id']
    @question_id = options['question_id']
  end

end
