<?php
	$dbhost = 'localhost:3306';
	$dbuser = 'root';
	$dbpass = 'breeze320681';
	$conn = mysqli_connect($dbhost, $dbuser, $dbpass);
	if (!$conn) {
		echo '{ "code" : 1, "info" : "Failed to connect mysql." }';
		die('');
	}
	mysqli_select_db($conn, 'cccs');
	
	if (isset($_GET["tid"])) {
		//tid=234&password=123&cid=233
		$tid = $_GET["tid"];
		$password = $_GET["password"];
		$cid = $_GET["cid"];
		
		$sql_query = "select * from Teacher where tid='$tid'";
		$retval = mysqli_query( $conn, $sql_query );
		$row = mysqli_fetch_array($retval, MYSQLI_ASSOC);
		if ($row['password'] != $password) {
			echo '{ "code" : 1, "info" : "Authentication failed." }';
			die('');
		}
		
		$sql_query = "select * from Course where tid='$tid' and cid='$cid'";
		$retval = mysqli_query( $conn, $sql_query );
		if (!($row = mysqli_fetch_array($retval, MYSQLI_ASSOC))) {
			echo '{ "code" : 1, "info" : "Course not found." }';
			die('');
		}

		$sql_query = "update Course set ".
			"started=0 ".
			"where cid='$cid' and tid='$tid'";
		mysqli_query( $conn, $sql_query );
		echo '{ "code" : 0, "info" : "Class stopped." }';
	}
	mysqli_close($conn);
?>
