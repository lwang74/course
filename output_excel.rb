require './CourseDb'
require './excel'
require 'json'

class Db < DbCourse
	def course_summary 
		sql=<<ABC
	Select r.Rname, su.SName, c.MaxN, se.cnt  
		, ca.Cname kemu, t.Tname teacher
		from Course c 
		Join Round r on r.ID=c.Rid
		Join Subject su on su.id=c.Sid
		Join Category ca on ca.ID=su.Cid
		Join Teacher t on t.ID=su.Tid
		Join (Select Cid, count(*) cnt from Sele group by Cid) se on se.Cid=c.ID
		Order by r.seq, ca.Cname, su.Sname
ABC
		data_arr=[]; round=nil
		@db[sql].each{|r|
			row =[]
			if round!=r[:rname]
				round=r[:rname]
				row<<r[:rname]
			else
				row<<nil
			end
			row<<r[:sname]
			row<<r[:kemu]
			row<<r[:teacher]
			row<<"#{r[:maxn]}"
			row<<r[:cnt]
			data_arr<<row
		}
		data_arr
	end

	def class_list
		sql=<<ABC
	Select s.ID stud_uid, s.sid stud_id, s.sname stud_name, c.cname class_name, g.cname grade_name, su.Sname subject_name, r.Rname round_name 
		, ca.Cname kemu, t.Tname teacher
		from Students s
		Left Join Class c on c.Id=s.Cid
		Left Join Grade g on g.ID=c.Gid
		Left Join Sele se on se.Sid=s.ID
		Left Join Course co on co.id=se.Cid
		left Join Round r on r.id=co.Rid
		left Join Subject su on su.Id=co.Sid
		Join Category ca on ca.ID=su.Cid
		Join Teacher t on t.ID=su.Tid
		Order by g.Cname, c.Cname
ABC
		@db[sql].map{|r|
			r
		}
	end

	def all_round
		sql=<<ABC
	Select Rname
		from Round 
		Order by Seq
ABC
		@db[sql].map{|r|
			r[:rname]
		}
	end
end

class CExcelOutPut
	def initialize temp_file, output_excel_file
		@temp_file=temp_file
		@output_excel_file=output_excel_file
	end

	def out_course data_course_summary, class_info, round_info
		excel = CExcel2.new
		excel.open_rw(@temp_file, @output_excel_file){|wb|
			sht=wb.worksheets(1)
			sht.Name='一览表'	
			excel.write_table(sht, sht.Range('A1'), data_course_summary)

			class_info.each{|sht_name, others|
				sht = wb.worksheets.Add(nil, sht)
				sht.Name = sht_name
				excel.write_table(sht, sht.Range('A1'), others)
			}

			# Round
			# p round_info
			round_info.each{|round_name, subjects|
				# p round_name
				sht = wb.worksheets.Add(nil, sht)
				sht.Name = round_name
				cnt=1
				subjects.each{|subject, people|
					excel.write_table(sht, sht.Range("A#{cnt}"), [[subject, '班级', '学号', '姓名']].concat(people))
					cnt+=people.size+2
				}
			}
		}
	end
end

def main
	file_name = 'download1.xlsx'

	out = CExcelOutPut.new('files/template.xlsx', "files/#{file_name}")
	db = Db.new
	# Summary
	summary = [['期次', '课程名称', '科目', '教师', '定员', '报名人数']].concat(db.course_summary())
	class_arr = db.class_list
	class_info = {}
	course_cross = db.all_round
	one_person_course = {}
	round_info = {}

	class_arr.each{|one|
		sht_name = "#{one[:grade_name]}#{one[:class_name]}"
		uid = one[:stud_uid]

		class_info[sht_name] ||= {}
		class_info[sht_name][uid] ||= {:id=>one[:stud_id], :name=>one[:stud_name], :sele=>Array.new(course_cross.size)}

		if one[:round_name]
			index = course_cross.index(one[:round_name])
			class_info[sht_name][uid][:sele][index] = one[:subject_name]

			subject_full = "#{one[:subject_name]} | #{one[:kemu]} | #{one[:teacher]}"
			round_info[one[:round_name]] ||= {}
			round_info[one[:round_name]][subject_full] ||= []
			round_info[one[:round_name]][subject_full] << [nil, one[:class_name], one[:stud_id], one[:stud_name]]
		end
	}

	# Class
	class_arr = {}
	class_info.each{|sht_name, others|
		class_arr[sht_name] ||= [['学号', '姓名'].concat(course_cross)]
		others.each{|uid, one|
			arr = [one[:id], one[:name]]
			arr.concat(one[:sele].flatten) if one[:sele]
			class_arr[sht_name] << arr
		}
	}

	out.out_course(summary, class_arr, round_info) 
end

if __FILE__==$0
	main
end

