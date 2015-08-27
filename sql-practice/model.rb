class Model

  def self.method_missing(meth_id, *args)
    meth_string = meth_id.to_s
    super(meth_id, *args) unless meth_string.start_with?('find_by_')
    meth_string.slice!(0..7)
    columns = meth_string.split('_and_')
    query_template = columns.join(' = ? and ').concat(' = ?')

    self.where([query_template, *args])
  end

  # bad string version
  def where_string(query)
    QuestionsDatabase.instance.execute(<<-SQL, query)
      SELECT  *
      FROM    #{self.class.table_name}
      WHERE   query
    SQL
  end

  def self.where(query)
    if query.is_a?(Hash)
      template = ''
      query.each { |key, _| template << "#{key.to_s} = :#{key.to_s} and " }
      template = template[0...-5]

      QuestionsDatabase.instance.execute(<<-SQL, query)
        SELECT  *
        FROM    #{self.table_name}
        WHERE   #{template}
      SQL
    elsif query[1].is_a?(Hash)
      QuestionsDatabase.instance.execute(<<-SQL, query.drop(1))
        SELECT  *
        FROM    #{self.table_name}
        WHERE   #{query.first}
      SQL
    else
      QuestionsDatabase.instance.execute(<<-SQL, *query.drop(1))
        SELECT  *
        FROM    #{self.table_name}
        WHERE   #{query.first}
      SQL
    end
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
