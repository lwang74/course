require './CourseBase'

class DbCourse
	def initialize
		@db = course_db("config/database.yml")
	end
end

if __FILE__==$0
	DbCourse.new
end
