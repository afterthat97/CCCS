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
	
	$username = $_GET["username"];
	$password = $_GET["password"];
	$type = $_GET["type"];

	
	if ($type == "Teacher") {
		$sql_query = "select * from Teacher where username='$username'";
		$retval = mysqli_query( $conn, $sql_query )//从库中选取对应老师
		
		//如果找到了对应的老师且匹配密码正确，则打印他的ID、姓名、性别、注册日期
		if ($row = mysqli_fetch_array($retval, MYSQLI_ASSOC)) {
			if ($row['password'] == $password) {
				echo '{ "code" : 0, "info" : "", ' .
					'"id" : ' . $row['tid'] . ', '.
					'"name" : "' . $row['name'] . '", '.
					'"gender" : "' . $row['gender'] . '", '.
					'"register_date" : "' . $row['register_date'] . '" }';
			} else {
				echo '{ "code" : 1, "info" : "Wrong username or password." }';
			}
		} else {
			echo '{ "code" : 1, "info" : "Wrong username or password." }';
		}
	} else if ($type == "Student") {
		$sql_query = "select * from Student where username='$username'";
		$retval = mysqli_query( $conn, $sql_query );//从库中选取学生
		
		//如果找到了对应的老师且匹配密码正确，则打印他的ID、姓名、性别、注册日期
		if ($row = mysqli_fetch_array($retval, MYSQLI_ASSOC)) {
			if ($row['password'] == $password) {
				echo '{ "code" : 0, "info" : "", ' .
					'"id" : ' . $row['sid'] . ', '.
					'"name" : "' . $row['name'] . '", '.
					'"gender" : "' . $row['gender'] . '", '.
					'"register_date" : "' . $row['register_date'] . '" }';
			} else {
				echo '{ "code" : 1, "info" : "Wrong username or password." }';
			}
		} else {
			echo '{ "code" : 1, "info" : "Wrong username or password." }';
		}
	}
	mysqli_close($conn);
?>
