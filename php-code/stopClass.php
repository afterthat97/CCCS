<?php
	$dbhost = 'localhost:3306';
	$dbuser = 'root';
	$dbpass = 'liudashi666';
	$conn = mysqli_connect($dbhost, $dbuser, $dbpass);
	if (!$conn) {
		echo '{ "code" : 1, "info" : "Failed to connect mysql." }';
		die('');
	}
	mysqli_select_db($conn, 'cccs');//修改数据库为cccs
	
	if (isset($_GET["tid"])) {
		//tid=234&password=123&cid=233
		//获取老师ID、password、课程ID
		$tid = $_GET["tid"];
		$password = $_GET["password"];
		$cid = $_GET["cid"];
		
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
        //更新与课程ID、教师ID匹配的相应课程表项，状态为下课，打印“课程结束”
		$sql_query = "update Course set ".
			"started=0 ".
			"where cid='$cid' and tid='$tid'";
		mysqli_query( $conn, $sql_query );
		echo '{ "code" : 0, "info" : "Class stopped." }';
	}
	mysqli_close($conn);
?>
