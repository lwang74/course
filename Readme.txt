﻿1 安装环境。--ruby环境已经有了，跳过。
2 安装数据库。--数据库已经有了，只需要清空。
	2.1 打开数据库管理器，选中Course库，按“新建查询”。
	2.2 双击db/Clear.bat可清空学生选课内容。
	2.3 双击db/Clear_all.bat则将数据库所有内容清空，之后须重新导入课程和学生。

3 填写课程Excel表，并导入至数据库。
	3.1 将填好的course.xls放至import路径下，双击course_import.bat将课程导入。
4 填写班级，学生Excel表，并导入至数据库。
	4.1 将填好的学生students.xls放至import路径下，双击students_import.bat将学生导入。
以上3，4也可颠倒顺序。

5 修改配置文件， --配置文件不动，跳过
6 启动服务。
	6.1 这Course路径下，双击Server.bat，启动一个黑窗口。
7 由学生选择课程。
	7.1 打开浏览器，在地址栏打入IP:4567即可让学生选择课程。
	7.2 在地址栏打入IP:4567/admin可由教师做修改用。
	7.3 在地址栏打入IP:4567/course可有教师做关闭部分课程用。
第7.1项可先由教师最试验或是测试环境用，之后在正式由学生选课之前，需执行Clear.sql清空选课内容。执行方法同Clear_all.sql。
注意Clear.sql只清空选课内容，而不会删除学生和课程本身。

8 输出结果Excel表。
	8.1 当所有学生选课结束后，双击output_excel.bat，在files路径下会生成一个download1.xlsx文件为结果文件。
