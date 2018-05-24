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
	
	//将库中的当前时间赋给cnt_time
	$sql_query = "select NOW() as cnt_time";
	$retval = mysqli_query( $conn, $sql_query );
	$row = mysqli_fetch_array($retval, MYSQLI_ASSOC);
	$cnt_time = $row['cnt_time'];
	
	if (isset($_GET["tid"])) {
		//tid=234&password=123&cid=233&latitude=1.1&longitude=2.2
		//获取老师ID、password、课程ID、经纬度
		$tid = $_GET["tid"];
		$password = $_GET["password"];
		$cid = $_GET["cid"];
		$latitude = $_GET["latitude"];
		$longitude = $_GET["longitude"];
		
		//检查老师密码是否匹配，若不匹配则打印“身份认证失败”并结束进程
		$sql_query = "select * from Teacher where tid='$tid'";
		$retval = mysqli_query( $conn, $sql_query );
		$row = mysqli_fetch_array($retval, MYSQLI_ASSOC);
		if ($row['password'] != $password) {
			echo '{ "code" : 1, "info" : "Authentication failed." }';
			die('');
		}
		
		//根据教师ID、课程ID匹配课程表相应条目，如果没有匹配项，则打印“找不到课程”并结束进程
		$sql_query = "select * from Course where tid='$tid' and cid='$cid'";
		$retval = mysqli_query( $conn, $sql_query );
		if (!($row = mysqli_fetch_array($retval, MYSQLI_ASSOC))) {
			echo '{ "code" : 1, "info" : "Course not found." }';
			die('');
		}

		//更新与课程ID、教师ID匹配的相应课程表项，状态为上课，同步更新开始时间为当前时间，经纬度为当前经纬度
		$sql_query = "update Course set ".
			"started=1, ".
			"start_time='$cnt_time', ".
			"latitude='$latitude', ".
			"longitude='$longitude' ".
			"where cid='$cid' and tid='$tid'";
		mysqli_query( $conn, $sql_query );
		
		//从选课表中匹配选了相应课程的学生ID，并在Checkin表中插入对应学生的状态条目。打印“课程开始”
		$sql_query = "select sid from Choose where cid='$cid'";
		$retval = mysqli_query( $conn, $sql_query );
		while ($row = mysqli_fetch_array($retval, MYSQLI_ASSOC)) {
			$sid = $row['sid'];
			$sql = "INSERT INTO Checkin".
					"(sid, cid, start_time, stat)".
					"VALUES".
					"('$sid', '$cid', '$cnt_time', 'Absent')";
			mysqli_query( $conn, $sql );
		}
		echo '{ "code" : 0, "info" : "Class started." }';
	}
	mysqli_close($conn);
?>
