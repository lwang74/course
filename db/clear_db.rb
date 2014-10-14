require 'yaml'
require 'sequel'

class DbStudents
	def initialize
		@db_cfg = YAML::load_file('../config/database.yml')['development']
		@db = Sequel.ado(:conn_string=>"Provider=SQLOLEDB;Connect Timeout=5;Data Source=#{@db_cfg['host']}; Initial Catalog=#{@db_cfg['database']}; Persist Security Info=False ;User ID=#{@db_cfg['username']}; Password=#{@db_cfg['password']};")
	end

	def clear 
		sql = 'TRUNCATE TABLE [Sele]'
		@db<<sql
	end

	def clear_all
		sql = [ 
			'TRUNCATE TABLE [Sele]',
			'DELETE [Course]',
			'DELETE [Round]',
			'DELETE [Students]',
			'DELETE [Subject]',
			'DELETE [Category]',
			'DELETE [Class]',
			'DELETE [Grade]',
			'DELETE [Teacher]',

			'DBCC CHECKIDENT ([Course], RESEED, 0)',
			'DBCC CHECKIDENT ([Round], RESEED, 0)',
			'DBCC CHECKIDENT ([Teacher], RESEED, 0)',
			'DBCC CHECKIDENT ([Subject], RESEED, 0)',
			'DBCC CHECKIDENT ([Category], RESEED, 0)',
			'DBCC CHECKIDENT ([Students], RESEED, 0)',
			'DBCC CHECKIDENT ([Class], RESEED, 0)',
			'DBCC CHECKIDENT ([Grade], RESEED, 0)'
		]
		sql.each{|one|
			# puts one
			@db<<one
		}
	end
end

def main
	db = DbStudents.new
	if 0==ARGV.size
		puts "只清除了学生选课内容。"
		db.clear
	elsif 1==ARGV.size and 'all'==ARGV[0]
		puts "清除了库中所有内容，请重新导入课程和学生。"
		db.clear_all
	else
		puts "Usage: ruby clear_db.rb [all]"
	end
end

main

