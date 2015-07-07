require 'byebug'
class User
  attr_accessor :id, :fname, :lname

  def self.table_name
    'users'
  end

  def self.find_by_id(id)
    User.new(QuestionsDatabase.instance.execute(<<-SQL, id).first
      SELECT
        *
      FROM
        users
      WHERE
        id = ?
    SQL
    )
  end

  def self.find_by_name(fname, lname)
    result = User.new(QuestionsDatabase.instance.execute(<<-SQL, fname, lname)
      SELECT
        *
      FROM
        users
      WHERE
        fname = ? AND lname = ?
    SQL
    )
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

  def table_data(has_id)
    instance_variables = self.instance_variables.map { |var| var.to_s[1..-1].to_sym }
    cols = {}
    instance_variables.each do |variable|
      cols[variable] = self.send(variable)
    end
    if has_id
      cols
    else
      cols.reject! {|k,v| k == :id}
    end
  end

  def table_cols(data, str = false)
    if str
      data.keys.map(&:to_s).join(', ')
    else
      ":#{data.keys.join(', :')}"
    end
  end

  def table_value_args(data)
    data.keys.drop(1).map { |key| "#{key.to_s}=:#{key.to_s}"  }.join(', ')
  end

  def save
    if @id.nil?
      data = table_data(false)
      QuestionsDatabase.instance.execute(<<-SQL, data)
        INSERT INTO #{self.class.table_name}(#{table_cols(data, true)})
        VALUES (#{table_cols(data)})
      SQL
      @id = QuestionsDatabase.instance.last_insert_row_id
    else
      data = table_data(true)
      QuestionsDatabase.instance.execute(<<-SQL, data)
        UPDATE #{self.class.table_name}
        SET #{table_value_args(data)}
        WHERE id = :id
      SQL
    end
  end

end
