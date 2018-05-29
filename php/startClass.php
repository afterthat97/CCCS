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
	
	$sql_query = "select NOW() as cnt_time";
	$retval = mysqli_query( $conn, $sql_query );
	$row = mysqli_fetch_array($retval, MYSQLI_ASSOC);
	$cnt_time = $row['cnt_time'];
	
	if (isset($_GET["tid"])) {
		//tid=234&password=123&cid=233&latitude=1.1&longitude=2.2
		$tid = $_GET["tid"];
		$password = $_GET["password"];
		$cid = $_GET["cid"];
		$latitude = $_GET["latitude"];
		$longitude = $_GET["longitude"];
		
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
			"started=1, ".
			"start_time='$cnt_time', ".
			"latitude='$latitude', ".
			"longitude='$longitude' ".
			"where cid='$cid' and tid='$tid'";
		mysqli_query( $conn, $sql_query );
		
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


		$sql_query = "select sid from temp where cid='$cid' and state='Allowed'";
		$retval = mysqli_query( $conn, $sql_query );
		while ($row = mysqli_fetch_array($retval, MYSQLI_ASSOC)) {
			$sid = $row['sid'];
			$sql = "UPDATE Checkin SET stat='Request For Leave' WHERE sid='$sid' and cid='$cid' and start_time='$cnt_time'";
			mysqli_query( $conn, $sql );
		}


		$sql_query = "DELETE FROM temp WHERE cid='$cid'";
		mysqli_query( $conn, $sql_query );

		echo '{ "code" : 0, "info" : "Class started." }';
	}
	mysqli_close($conn);
?>
