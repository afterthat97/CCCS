<?php
	$dbhost = 'localhost:3306';
	$dbuser = 'root';
	$dbpass = 'liudashi666';
	$conn = mysqli_connect($dbhost, $dbuser, $dbpass);
	if (!$conn) {
		echo '{ "code" : 1, "info" : "Failed to connect to database." }';
		die('');
	}
	mysqli_select_db($conn, 'cccs');//修改数据库为cccs
	
	//甄别是教师ID还是学生ID，若是教师ID，则是要创建新课程；若是学生ID，则是要选课
	if (isset($_GET["tid"])) {
		// tid=234&password=123&name=AI&place=West1&credit=3
		//获取老师的ID、password、课程名、上课地点、学分
		$tid = $_GET["tid"];
		$password = $_GET["password"];
		$name = $_GET["name"];
		$place = $_GET["place"];
		$credit = $_GET["credit"];
		
		//检查是否已经有相应课程，是的话结束打印“课程已存在”，并结束进程
		$sql_query = "select * from Course where name='$name' and tid='$tid'";
		$retval = mysqli_query( $conn, $sql_query );
		if ($row = mysqli_fetch_array($retval, MYSQLI_ASSOC)) {
			echo '{ "code" : 1, "info" : "Course already exists." }';
			die('');
		}

		//从教师表中获取教师ID，检查密码是否匹配，若匹配，则在课程表中插入新一条，并打印“添加课程成功”；否则打印“身份认证失败”
		$sql_query = "select * from Teacher where tid='$tid'";
		$retval = mysqli_query( $conn, $sql_query );
		$row = mysqli_fetch_array($retval, MYSQLI_ASSOC);
		if ($row['password'] == $password) {
			$sql = "INSERT INTO Course".
					"(tid, name, place, credit, started)".
					"VALUES".
					"('$tid', '$name', '$place', '$credit', false)";
			mysqli_query( $conn, $sql );
			echo '{ "code" : 0, "info" : "Course has been added." }';
		} else {
			echo '{ "code" : 1, "info" : "Authentication failed." }';
		}
	} else {
		// sid=123&password=666&name=AI&teacher=liulaoshi
		//获取学生的ID、password、课程名、任课老师名
		$sid = $_GET["sid"];
		$password = $_GET["password"];
		$name = $_GET["name"];
		$teacher = $_GET["teacher"];


		$sql_query = "select * from Teacher a, Course b where a.tid=b.tid and a.name='$teacher' and b.name='$name'";
		$retval = mysqli_query( $conn, $sql_query );//从教师表和课程表中选出教师ID对应，且与课程名、教师名匹配的行
		//检查课程编号是否匹配，若不匹配则打印“未找到课程”
		if ($row = mysqli_fetch_array($retval, MYSQLI_ASSOC)) {
			$cid = $row['cid'];
		} else {
			echo '{ "code" : 1, "info" : "Course not found." }';
			die('');
		}

		//从学生表中获取学生ID，检查密码是否匹配，若匹配，则在选课表中新插入一行，并打印“课程添加成功”；否则打印“身份认证失败”
		$sql_query = "select * from Student where sid='$sid'";
		$retval = mysqli_query( $conn, $sql_query );
		$row = mysqli_fetch_array($retval, MYSQLI_ASSOC);
		if ($row['password'] == $password) {
			$sql = "INSERT INTO Choose".
					"(cid, sid)".
					"VALUES".
					"('$cid', '$sid')";
			mysqli_query( $conn, $sql );
			echo '{ "code" : 0, "info" : "Course has been added." }';
		} else {
			echo '{ "code" : 1, "info" : "Authentication failed." }';
		}
	}
	mysqli_close($conn);
?>
