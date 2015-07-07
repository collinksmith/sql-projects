require_relative 'requirements'

class QuestionsDatabase < SQLite3::Database
  include Singleton

  def initialize
    super('questions.db')
    self.results_as_hash = true
    self.type_translation = true
  end

end


j = User.new({'fname' => 'Judy', 'lname' => 'Wacker'})

j.save

# p Question.find_by_id(1)
# p Question.find_by_author_id(1)
