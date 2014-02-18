Encoding.default_internal = "UTF-8"

%w[rubygems sinatra haml sinatra/reloader sinatra/config_file json sequel yaml ./CourseBase].each{ |gem| require gem } 


configure do  
	set :db, course_db("config/database.yml")

	# database_config = YAML.load_file("config/database.yml")
	# dev = database_config['development']
	# set :db, Sequel.ado(:conn_string=>"Provider=SQLOLEDB;Connect Timeout=5;Data Source=#{dev['host']}; Initial Catalog=#{dev['database']}; Persist Security Info=False ;User ID=#{dev['username']}; Password=#{dev['password']};")

	# set :db, Sequel.ado(:conn_string=>'Provider=SQLOLEDB;Connect Timeout=5;Data Source=localhost\sqlexpress; Initial Catalog=Course; Persist Security Info=False ;User ID=sa; Password=naomi_94167;')
	# set :db, Sequel.ado(:conn_string=>'Provider=SQLOLEDB;Connect Timeout=5;Data Source=192.168.199.128; Initial Catalog=Course; Persist Security Info=False ;User ID=sa; Password=naominaomi;')

		# @db = Sequel.ado(:conn_string=>'Provider=Microsoft.Jet.OLEDB.4.0;Data Source=Course.mdb')
		# @db = Sequel.connect('ado://sa:naomi_94167@localhost/Course?host=localhost%sqlexpress&provider=SQLNCLI10')

	# set :port, 80

	round_cnt_sql=<<ABC
select COUNT(*) cnt from ( 
	SELECT Distinct r.ID,r.Rname
	  FROM [Course].[dbo].[Course] c
	  JOIN [Course].[dbo].[Round] r on r.ID=c.Rid
) a
ABC
		ret=-1
		settings.db[round_cnt_sql].each{|r|
			ret=r[:cnt].to_i
		}
		ret
	set :round_cnt, ret
end

configure :development do
end

helpers do
	alias_method :h, :escape_html

	def get_grade
		sql="Select ID, cname from Grade g order by Cname"
		settings.db[sql].map{|r|
			r
			# [r[:id], r[:cname]]
		}
	end
	
	def get_class grade_id
		sql=<<ABC
	Select ID, Cname from Class c 
		where c.Gid=#{grade_id}
		order by Cname
ABC
		settings.db[sql].map{|r|
			r
			# [r[:id], r[:cname]]
		}
	end

	def get_students class_id, all_stud
		part_stud = "and (sl.cnt is null or sl.cnt<#{settings.round_cnt})"
		if all_stud
			part_stud = ""
		end
		sql=<<ABC
	Select ID, s.Sid, Sname from Students s
		left Join (select Sid, count(*) cnt From Sele group by Sid) sl on sl.Sid=s.ID 
		where Cid=#{class_id} #{part_stud}
		order by Sname
ABC
		settings.db[sql].map{|r|
			r
			# [r[:id], r[:sname]]
		}
	end

	def get_all_course grade_id, student_id=-1
		student_id=-1 if !student_id
		sql=<<ABC
	SELECT c.ID course_id, isnull(c.Disable,0) Disable
		, s.ID subject_id, s.Sname subject_name, t.Tname teacher_name, ca.Cname category_name, r.ID round_id, r.Rname round_name, c.MaxN, c.MinN, isnull(s1.Cnt,0) curr_count, s.descr 
  			, sel.Cid selected_cid
  		FROM [dbo].[Course] c
  		Join [dbo].[Subject] s on s.ID=c.Sid
  		Join [dbo].[Teacher] t on t.ID=s.Tid
  		Join [dbo].[Category] ca on ca.ID=s.Cid
  		Join [dbo].[Round] r on r.ID=c.Rid
		Left Join (Select Cid, count(*) Cnt from Sele group by Cid) s1 on s1.Cid=c.Id
		Left Join 
			(Select s.Cid, s.Sid 
				from Sele s 
				WHERE s.Sid=#{student_id}) sel on sel.Cid=c.ID
  		Where ca.Gid=#{grade_id}
  		Order by r.Seq, r.Rname, ca.Cname, s.Sname
ABC
		get_course_sub sql
	end

	def get_all_course_order_by_cnt grade_id
		sql=<<ABC
	SELECT c.ID course_id, isnull(c.Disable,0) Disable
		, s.ID subject_id, s.Sname subject_name, t.Tname teacher_name, ca.Cname category_name, r.ID round_id, r.Rname round_name, c.MaxN, c.MinN, isnull(s1.Cnt,0) curr_count, s.descr 
  		FROM [dbo].[Course] c
  		Join [dbo].[Subject] s on s.ID=c.Sid
  		Join [dbo].[Teacher] t on t.ID=s.Tid
  		Join [dbo].[Category] ca on ca.ID=s.Cid
  		Join [dbo].[Round] r on r.ID=c.Rid
		Left Join (Select Cid, count(*) Cnt from Sele group by Cid) s1 on s1.Cid=c.Id
  		Where ca.Gid=#{grade_id}
  		Order by s1.Cnt desc, r.Seq, r.Rname, ca.Cname, s.Sname
ABC
		get_course_sub sql
	end

# 	def get_course student_id
# 		sql=<<ABC
# 	SELECT c.ID, c.Cname, r.ID Rid, r.Rname, c.MaxN, c.MinN , s.Sid, s.Sname, isnull(s1.Cnt, 0) Cnt
# 		FROM Course c
# 		Join Round AS r on r.ID=c.Rid
# 		Left Join 
# 			(Select s.CID Cid, st.ID Sid, st.Sname 
# 				from Sele s 
# 				Join Students st on st.ID=s.Sid 
# 				WHERE s.Sid=#{student_id}) s on s.Sid=c.ID
# 		Left Join (Select Cid, count(*) Cnt from Sele group by Cid) s1 on s1.Cid=c.Cid
# 		ORDER BY r.Seq, c.Cname;
# ABC
# 		get_course_sub sql
# 	end

	def get_course_sub sql
		ret={}
		settings.db[sql].each{|r|
			ret[r[:round_id]] ||= {:round_name=>r[:round_name], :course=>[]}
			ret[r[:round_id]][:course] << r
			# [r[:id], r[:subject_name], r[:teacher_name], r[:maxn], r[:minn], r[:cnt], r[:sid]]
		}
		ret
	end

	def check_it student_id, course_ids
		sql=<<ABC
	Select s.Cid, s.currCnt, isNull(usedCnt,0) usedCnt, c.MaxN from (
		Select s.Cid, Count(s.Cid) currCnt From [dbo].[Sele] s
			where s.Cid in (#{course_ids.join(',')})
			group by s.Cid) s
		Left join (Select Cid, count(Cid) usedCnt from [dbo].[Sele] where Sid=#{student_id}
			group by Cid) sc on sc.Cid=s.Cid
		join [dbo].[Course] c on c.Id=s.Cid
ABC
		over =false
		settings.db[sql].map{|r|
			puts "#{r[:currcnt]}==#{r[:usedcnt]}"
			currCnt = r[:currcnt].to_i-r[:usedcnt].to_i+1
			over ||=currCnt>r[:maxn].to_i
		}
		p over
		over
	end

	def del_sele student_id
		sql=<<ABC
	Delete Sele where Sid=?
ABC
		insert_ds = settings.db[sql, student_id]
		insert_ds.insert
	end

	def ins_sele student_id, course_ids
		sql=<<ABC
	Insert into Sele (Sid, Cid) values (?,?)
ABC
		course_ids.each{|cid|
			insert_ds = settings.db[sql, student_id, cid]
			insert_ds.insert
		}
	end

	def set_course_disable course_ids
		sql=<<ABC
	Update Course Set Disable=1 Where ID in (#{course_ids.join(',')})
ABC
		update_ds = settings.db[sql]
		update_ds.update
		sql=<<ABC
	Delete Sele Where Cid in (#{course_ids.join(',')})
ABC
		ds = settings.db[sql]
		ds.delete
	end

	def download_excel_file file_name
		sql=<<ABC
	Select * from Course c 
		Join Round r on r.ID=c.Rid
		Join Subject s on s.id=c.Sid
		Left Join (Select Cid, count(*) cnt from Sele group by Cid) se on se.Cid=c.ID
		Order by r.seq, s.Sname
ABC
		data_arr=[]; round=nil
		settings.db[sql].each{|r|
			row =[]
			if round!=r[:rname]
				round=r[:rname]
				row<<r[:rname]
			else
				row<<nil
			end
			row<<r[:sname]
			row<<"#{r[:minn]}/#{r[:maxn]}"
			row<<r[:cnt]
			data_arr<<row
		}
		data_arr
	end

end

before do
  content_type :html, 'charset' => 'utf-8'
end

get '/' do
	@tRound = settings.round_cnt
	@grade = get_grade()
	@all_stud=false
	@loc = '/'
	haml :index
end

# 显示所有学生
get '/admin' do
	@tRound = settings.round_cnt
	@grade = get_grade()
	@all_stud=true
	@loc = '/admin'
	haml :index, :layout=>:layout_admin
end

# get '/class_by_grade' do
# 	@class = get_class()
# 	haml :class, :layout=>false
# end

post '/get_classes' do
	grade_id = params[:grade_select]
	@classes = get_class(grade_id)
	@all_stud = params[:all_stud]=='true'
	haml :class_select, :layout=>false
end

post '/get_students' do
	@students = get_students(params[:class_select], params[:all_stud]=='true')
	haml :student_select, :layout=>false
end

post '/get_course' do
	# @course = get_course(params[:student_select])
	grade_id = params[:grade_select]
	student_id = params[:student_select]
	@course = get_all_course(grade_id, student_id)
	haml :course_select, :layout=>false
end

post '/set_course' do
# post '/' do
# {"grade_select"=>"2", "class_select"=>"5", "student_select"=>"20288", "N_2"=>"17", "N_3"=>"24"}
	student_id = -1
	course_ids ={} #{rand=>course_id}
	params.each{|key, val|
		if key=='student_select'
			student_id = val.to_i 
		elsif /^HN_(\d+)_(\d+)$/=~key #隐藏旧选择项
			if '1'==val
				course_ids[$1] = $2.to_i
			end
		end
	}

	# p params.to_json
	params.each{|key, val|	#new select
		if /^N_(\d+)$/=~key
			course_ids[$1] = val.to_i
		end
	}
	if student_id>0 and course_ids.size==settings.round_cnt
		@course_ids_list = course_ids.map{|k, v| v}
		if !check_it(student_id, @course_ids_list)
			del_sele(student_id)
			ins_sele(student_id, @course_ids_list)
			@result = {:err=>false, :msg=>"保存成功！"}
		else
			@result = {:err=>true, :msg=>"选择失败, 请刷新界面，重新选择！"}
		end
	else
		@result = {:err=>true, :msg=>"选择失败, 请检查！"}
	end
	haml :subm, :layout=>false

	# "#{student_id}=#{course_ids.join('-')}"
	# params
	# @post = params[:post]
end

# ######################################
# 用于关闭某些课程
get '/course' do
	@grade = get_grade()
	haml :course
end

post '/get_course_in_course' do
	grade_id = params[:grade_select]
	@course = get_all_course_order_by_cnt(grade_id)
	haml :course_adjust, :layout=>false
end

post '/change_course' do
	# ["grade_select", "2"]["N_21", "1"]["N_22", "1"]["N_23", "1"]["N_26", "1"]["N_27", "1"]
	course_ids=[]
	params.each{|key, val|
		if /^N_(\d+)$/=~key
			course_ids<<$1
		end
	}
	set_course_disable(course_ids)
	'成功！'
end

# ######################################
get '/cat' do
	@grade = get_grade()
	haml :cat
end
post '/cat' do
	@grade = get_grade()
	haml :cat
end

get '/test' do
  if settings.development?
    "development!"
  else
    "not development!"
  end
end

get '/download' do
	file_name = 'download1.xlsx'

	out = CExcelOutPut.new('files/template.xlsx', "files/#{file_name}")
	data_arr = download_excel_file(file_name)
	# data_arr.to_json
	out.out_round_summary(data_arr)
	send_file "./files/#{file_name}", :filename =>"#{file_name}", :type => 'Application/octet-stream'
end

# get '/:file_name' do |file_name|
  # p 'file_name=>'
  # p file_name
  # attachment 'public/'+file_name
  # file_name
#   "#{file_name}!"
# end

get '/test1' do
	haml :layout
end
