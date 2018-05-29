<?php
	$dbhost = 'localhost:3306';
	$dbuser = 'root';
	$dbpass = 'breeze320681';
	$conn = mysqli_connect($dbhost, $dbuser, $dbpass);
	if (!$conn) {
		echo '{ "code" : 1, "info" : "Failed to connect to database." }';
		die('');
	}
	mysqli_select_db($conn, 'cccs');
	
	if (isset($_GET["tid"])) {
		// tid=234&password=123&name=AI&place=West1&credit=3
		$tid = $_GET["tid"];
		$password = $_GET["password"];
		$name = $_GET["name"];
		$place = $_GET["place"];
		$credit = $_GET["credit"];
		
		$sql_query = "select * from Course where name='$name' and tid='$tid'";
		$retval = mysqli_query( $conn, $sql_query );
		if ($row = mysqli_fetch_array($retval, MYSQLI_ASSOC)) {
			echo '{ "code" : 1, "info" : "Course already exists." }';
			die('');
		}

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
		$sid = $_GET["sid"];
		$password = $_GET["password"];
		$name = $_GET["name"];
		$teacher = $_GET["teacher"];

		$sql_query = "select * from Teacher a, Course b where a.tid=b.tid and a.name='$teacher' and b.name='$name'";
		$retval = mysqli_query( $conn, $sql_query );
		if ($row = mysqli_fetch_array($retval, MYSQLI_ASSOC)) {
			$cid = $row['cid'];
		} else {
			echo '{ "code" : 1, "info" : "Course not found." }';
			die('');
		}

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
