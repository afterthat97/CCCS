<?php
	$dbhost = 'localhost:3306';
	$dbuser = 'root';
	$dbpass = 'liudashi666';
	$conn = mysqli_connect($dbhost, $dbuser, $dbpass);
	if (!$conn) {
		echo '{ "code" : 1, "info" : "Failed to connect to database." }';
		die('');
	}
	mysqli_select_db($conn, 'cccs')//修改数据库为cccs
	
	//将库中的当前时间赋给cnt_time
	$sql_query = "select NOW() as cnt_time";
	$retval = mysqli_query( $conn, $sql_query );//从库中选取当前时间
	$row = mysqli_fetch_array($retval, MYSQLI_ASSOC);//从结果集中取出一行作为关联数组
	$cnt_time = $row['cnt_time'];//将当前时间赋值给cnt_time
	
	if (isset($_GET["sid"])) {
		//sid=234&password=123&cid=233&latitude=1.1&longitude=2.2
		//获取学生的ID、password、courseID、经纬度
		$sid = $_GET["sid"];
		$password = $_GET["password"];
		$cid = $_GET["cid"];
		$latitude = $_GET["latitude"];
		$longitude = $_GET["longitude"];
		
		//匹配密码
		$sql_query = "select * from Student where sid='$sid'";
		$retval = mysqli_query( $conn, $sql_query );
		$row = mysqli_fetch_array($retval, MYSQLI_ASSOC);
		if ($row['password'] != $password) {
			echo '{ "code" : 1, "info" : "Authentication failed" }';
			die('');
		}
		
		//匹配数据库中的course表
		$sql_query = "select * from Course where cid='$cid'";
		$retval = mysqli_query( $conn, $sql_query );
		if (!($row = mysqli_fetch_array($retval, MYSQLI_ASSOC))) {//检查课程是否存在
			echo '{ "code" : 1, "info" : "Course not found" }';
			die('');
		} else {
			$started = $row['started'];//检查课程是否开始
			if ($started == "0") {
				echo '{ "code" : 1, "info" : "Course has not started" }';
				die('');
			}
			//获取上课时间和老师位置
			$start_time = $row['start_time'];
			$teacher_latitude = $row['latitude'];
			$teacher_longitude = $row['longitude'];
			
			//根据经纬度算师生之间距离
			$latitude_diff = $teacher_latitude - $latitude;
			$longitude_diff = $teacher_longitude - $longitude;

			$pi = 3.14159268979;
			$latitude_diff = sin($latitude_diff * $pi / 180.0) * 6378137.0;
			$longitude_diff = sin($longitude_diff * $pi / 180.0) * 6378137.0;

			$distance = (int)sqrt($latitude_diff * $latitude_diff + $longitude_diff * $longitude_diff);

			if ($distance > 100) {
				echo '{ "code" : 1, "info" : "You are too far away. (distance: '."$distance".'m)" }';
				die('');
			}
			
			//匹配Checkin表，若没有相应条目则创建一个，再匹配
			$sql_query = "select stat from Checkin where sid='$sid' and cid='$cid' and start_time='$start_time';";
			$retval = mysqli_query( $conn, $sql_query );
			if (!($row = mysqli_fetch_array($retval, MYSQLI_ASSOC))) {
				$sql = "INSERT INTO Checkin".
						"(sid, cid, start_time, stat)".
						"VALUES".
						"('$sid', '$cid', '$start_time', 'Absent')";
				mysqli_query( $conn, $sql );
				$sql_query = "select stat from Checkin where sid='$sid' and cid='$cid' and start_time='$start_time';";
				$retval = mysqli_query( $conn, $sql_query );
				$row = mysqli_fetch_array($retval, MYSQLI_ASSOC);
			}

			//若学生状态不为缺席，则说明已经签过到
			if ($row['stat'] != "Absent") {
				echo '{ "code" : 1, "info" : "You have already checked in. (distance: '."$distance".'m)" }';
				die('');
			}
			
			//检查学生ID、courseid、开课时间，若当前时间与上课时间差值2分钟内，则签到成功，否则迟到
			$sql_query = "select TIME_TO_SEC(TIMEDIFF(NOW(), a.start_time)) as diff from (select start_time from Course where cid='$cid') a";
			$retval = mysqli_query( $conn, $sql_query );
			$row = mysqli_fetch_array($retval, MYSQLI_ASSOC);
			if ($row['diff'] <= 120) {
				$sql_query = "update Checkin set stat='Normal', checkin_time=NOW() where sid='$sid' and cid='$cid' and start_time='$start_time';";
				$retval = mysqli_query( $conn, $sql_query );
				echo '{ "code" : 0, "info" : "You have checked in successfully. (distance: '."$distance".'m)" }';
			} else {
				$sql_query = "update Checkin set stat='Late', checkin_time=NOW() where sid='$sid' and cid='$cid' and start_time='$start_time';";
				$retval = mysqli_query( $conn, $sql_query );
				echo '{ "code" : 0, "info" : "Sorry, you are late. (distance: '."$distance".'m)" }';
			}
		}
	}
	mysqli_close($conn);
?>
