class Model

  def initialize(hash)

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
