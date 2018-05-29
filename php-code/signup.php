<?php
	$dbhost = 'localhost:3306';
	$dbuser = 'root';
	$dbpass = 'liudashi666';
	$conn = mysqli_connect($dbhost, $dbuser, $dbpass);
	if( !$conn ) {
		echo '{ "code" : 1, "info" : "Failed to connect to database." }';
		die('');
	}
	mysqli_select_db($conn, 'cccs');//修改数据库为cccs
	
	//获取用户的用户名、密码、类别、性别、姓名
	$username = $_GET["username"];
	$password = $_GET["password"];
	$type = $_GET["type"];
	$gender = $_GET["gender"];
	$name = $_GET["name"];
	
	//从对应的类别的表中根据名字匹配用户
	$sql_query = "select * from $type where username='$username'";
	$retval = mysqli_query( $conn, $sql_query );
	
	//若在表中有对应的匹配，则打印“用户已注册”；若无，则插入一条新的表项，并打印“注册成功”
	if ($row = mysqli_fetch_array($retval, MYSQLI_ASSOC)) {
		echo '{ "code" : 1, "info" : "Username already exists." }';
	} else {
		$sql = "INSERT INTO $type".
				"(username, password, name, gender, register_date)".
				"VALUES".
				"('$username', '$password', '$name', '$gender', NOW())";
		mysqli_query( $conn, $sql );
		echo '{ "code" : 0, "info" : "You have registered succussfully!" }';
	}
	mysqli_close($conn);
?>
