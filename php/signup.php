<?php
	$dbhost = 'localhost:3306';
	$dbuser = 'root';
    $dbpass = 'breeze320681';
	$conn = mysqli_connect($dbhost, $dbuser, $dbpass);
	if( !$conn ) {
		echo '{ "code" : 1, "info" : "Failed to connect to database." }';
		die('');
	}
	mysqli_select_db($conn, 'cccs');
	
	$username = $_GET["username"];
	$password = $_GET["password"];
	$type = $_GET["type"];
	$gender = $_GET["gender"];
	$name = $_GET["name"];
	
	$sql_query = "select * from $type where username='$username'";
	$retval = mysqli_query( $conn, $sql_query );
	
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
