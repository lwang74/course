require "dbi"

class Db
	def initialize db_config
		@conn="DBI:ADO:Provider=SQLOLEDB;Connect Timeout=5;Data Source=#{db_config['host']}; Initial Catalog=#{db_config['database']}; Persist Security Info=False ;User ID=#{db_config['username']}; Password=#{db_config['password']};"
	end
	
	def get_ins_id dbh
	    sth=dbh.prepare("select @@identity")
	    sth.execute
	    row = sth.fetch
	    sth.finish
	    row[0]
	end

	def exec_s &dbh
		dbh=DBI.connect(@conn)
		dbh['AutoCommit'] = true
		yield dbh
		dbh.disconnect
	end

	def exec_sql sql, &row
	    dbh=DBI.connect(@conn)
	    
	    sth=dbh.prepare(sql)
	    sth.execute
	    while row=sth.fetch do
	      yield row
	    end
	    sth.finish
	    dbh.disconnect
	end
end

class DB2<Db
	def exec sql
		if !@dbh
			@dbh = DBI.connect(@conn)
			@dbh['AutoCommit'] = true
		end
		@dbh.execute(sql)
	end
	def close
	    @dbh.disconnect
	end
end

if __FILE__==$0
	db2 = DB2.new({'host'=> "10.191.4.174", 'database'=> 'ICT_Ref', 'username'=> 'sa', 'password'=>'sa'})
	#~ db2.exec "insert into comp_type (type) values ('lwang1')"
	db2.exec "update comp_type set type='lwang' where type='lwang3'"
	db2.close

	db = Db.new({'host'=> "10.191.4.174", 'database'=> 'ICT_Ref', 'username'=> 'sa', 'password'=>'sa'})
	db.exec_sql("select * from comp_type"){|row|
		p row
	}
end




