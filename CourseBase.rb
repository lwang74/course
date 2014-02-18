require 'yaml'
require 'sequel'

def course_db database_yml
	database_config = YAML.load_file(database_yml)
	dev = database_config['development']
	Sequel.ado(:conn_string=>"Provider=SQLOLEDB;Connect Timeout=5;Data Source=#{dev['host']}; Initial Catalog=#{dev['database']}; Persist Security Info=False ;User ID=#{dev['username']}; Password=#{dev['password']};")
end
