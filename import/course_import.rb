require 'yaml'
require 'sequel'
require './excel'

class DbCourse
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

	def ins_category category_name, grade_id
		sql = "Select * from Category Where Cname='#{category_name}' and Gid=#{grade_id}"
		ret = @db[sql].map{|r| r}
		if ret.size==0
			insert_ds = @db["Insert into Category (Cname, Gid) values (?,?)", category_name, grade_id]
			insert_ds.insert
			ret = ins_category(category_name, grade_id)
		end
		ret
	end

	def ins_teacher teacher_name
		sql = "Select * from Teacher Where Tname='#{teacher_name}'"
		ret = @db[sql].map{|r| r}
		if ret.size==0
			insert_ds = @db["Insert into Teacher (Tname) values (?)", teacher_name]
			insert_ds.insert
			ret = ins_teacher(teacher_name)
		end
		ret
	end

	def ins_round round_name
		sql = "Select * from Round Where Rname='#{round_name}'"
		ret = @db[sql].map{|r| r}
		if ret.size==0
			insert_ds = @db["Insert into Round (Rname, Seq) select ?, isNull(max(Seq),0)+1 Seq from Round", round_name]
			insert_ds.insert
			ret = ins_round(round_name)
		end
		ret
	end

	def ins_subject subject_name, subject_desc, teacher_id, category_id
		sql = "Select * from Subject Where Sname='#{subject_name}'"
		ret = @db[sql].map{|r| r}
		if ret.size==0
			insert_ds = @db["Insert into Subject (Sname, Descr, Tid, Cid) values (?,?,?,?)", subject_name, subject_desc, teacher_id, category_id]
			insert_ds.insert
			ret = ins_subject(subject_name, subject_desc, teacher_id, category_id)
		end
		ret
	end

	def ins_course maxn, minn, subject_id, round_id
		sql = "Select * from Course Where Sid=#{subject_id} And Rid=#{round_id}"
		ret = @db[sql].map{|r| r}
		if ret.size==0
			insert_ds = @db["Insert into Course (Sid, Rid, MaxN, MinN) values (?,?,?,?)", subject_id, round_id, maxn, minn]
			insert_ds.insert
			ret = ins_course(maxn, minn, subject_id, round_id)
		end
		ret
	end

	def ins_one_sheet grade_name
		grade = ins_grade(grade_name)
		grade[0][:id]
	end

	def ins_one_line grade_id, row_arr
		# rand, course_name, category_name, teacher, maxn, minn, desc
		category = ins_category(row_arr[2], grade_id)
		round = ins_round(row_arr[0])
		teacher = ins_teacher(row_arr[3])
		subject = ins_subject(row_arr[1], row_arr[6], teacher[0][:id], category[0][:id])
		course = ins_course(row_arr[4], row_arr[5], subject[0][:id], round[0][:id])
	end
end

def main
	db = DbCourse.new
	
	# 期次	课程名称	科目	教师	定员	最少人数	简要说明
	CExcel.new.open_read('course.xls'){|wb|
		wb.Worksheets.each{|sht|
			# p sht.name
			grade_id = db.ins_one_sheet(sht.name)
			cnt=0
			sht.usedrange.value2.each{|row|
				if 0!=cnt
					# p row[0]
					db.ins_one_line grade_id, row
				end
				cnt+=1
			}
		}
	}
end

main
