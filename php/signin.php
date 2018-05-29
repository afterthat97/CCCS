<?php
    //使用用户名和密码登录服务器上的mysql，mysql的默认端口是3306
	$dbhost = 'localhost:3306';
	$dbuser = 'root';
	$dbpass = 'breeze320681';
	$conn = mysqli_connect($dbhost, $dbuser, $dbpass);
    //conn-判断连接是否成功的状态量
	if (!$conn) {
		echo '{ "code" : 1, "info" : "Failed to connect to database." }';
		die('');
	}
	mysqli_select_db($conn, 'cccs');
	
    //$_GET从获得的URL中获取username，password，type等信息
	$username = $_GET["username"];
	$password = $_GET["password"];
	$type = $_GET["type"];

	
	if ($type == "Teacher") {
		$sql_query = "select * from Teacher where username='$username'";
		$retval = mysqli_query( $conn, $sql_query );//retval记录查询返回值
		
        //根据username提取对应的一行数据，判断密码是否输对，并echo其他的信息
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
		$retval = mysqli_query( $conn, $sql_query );
		
		if ($row = mysqli_fetch_array($retval, MYSQLI_ASSOC)) {
			if ($row['password'] == $password) {
                //这边除了其他的信息，也返回了一个code值，用于告知前端是否登录成功
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
