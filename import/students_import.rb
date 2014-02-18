require 'yaml'
require 'sequel'
require './excel'

class DbStudents
	def initialize
		@db_cfg = YAML::load_file('../config/database.yml')['development']
		@db = Sequel.ado(:conn_string=>"Provider=SQLOLEDB;Connect Timeout=5;Data Source=#{@db_cfg['host']}; Initial Catalog=#{@db_cfg['database']}; Persist Security Info=False ;User ID=#{@db_cfg['username']}; Password=#{@db_cfg['password']};")
	end

	def ins_grade grade_name
		sql = "Select * from Grade Where Cname='#{grade_name}'"
		ret = @db[sql].map{|r| r}
		if ret.size==0
			insert_ds = @db["Insert into Grade (Cname) values (?)", grade_name]
			insert_ds.insert
			ret = ins_grade(grade_name)
		end
		ret
	end

	def ins_class class_name, grade_id
		sql = "Select * from Class Where Cname='#{class_name}' and Gid=#{grade_id}"
		ret = @db[sql].map{|r| r}
		if ret.size==0
			insert_ds = @db["Insert into Class (Cname, Gid) values (?,?)", class_name, grade_id]
			insert_ds.insert
			ret = ins_class(class_name, grade_id)
		end
		ret
	end

	def ins_student stud_id, stud_name, class_id
		sql = "Select * from Students Where Sid='#{stud_id}' And Sname='#{stud_name}' And Cid=#{class_id}"
		ret = @db[sql].map{|r| r}
		if ret.size==0
			insert_ds = @db["Insert into Students (Sid, Sname, Cid) values (?,?,?)", "#{stud_id}", stud_name, class_id]
			insert_ds.insert
			ret = ins_student(stud_id, stud_name, class_id)
		end
		ret
	end

	def ins_one_sheet grade_class_name
		class_id=nil
		if /^(.+)(\d+.+$)/=~grade_class_name
			grade_name = $1
			class_name = $2
			grade = ins_grade(grade_name)
			class_arr = ins_class(class_name, grade[0][:id])
			class_id=class_arr[0][:id]
		end
		class_id
	end

	def ins_one_line class_id, row_arr
		# id, students_name
		student = ins_student(row_arr[0], row_arr[1], class_id)
	end
end

def main
	db = DbStudents.new
	
	# 学籍号	姓名 
	CExcel.new.open_read('students.xls'){|wb|
		wb.Worksheets.each{|sht|
			p sht.name
			class_id = db.ins_one_sheet(sht.name)
			cnt=0
			sht.usedrange.value.each{|row|
				if 0!=cnt
					# p row
					if row[0].class==Float
						row[0]=row[0].to_s
						if /^(.+)\.0$/=~row[0]
							row[0] = $1
						end 
					end
					p row
					db.ins_one_line class_id, row
				end
				cnt+=1
			}
		}
	}
end

main
