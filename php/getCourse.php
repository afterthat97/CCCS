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
		$tid = $_GET["tid"];
		$sql_query = "select a.*, b.name as teacher from Course a, Teacher b where a.tid=b.tid and a.tid='$tid'";
	} else {
		$sid = $_GET["sid"];
		$sql_query = "select b.*, a.name as teacher from Teacher a, Course b, Choose c where a.tid=b.tid and b.cid=c.cid and sid='$sid'";
	}
	
	$retval = mysqli_query( $conn, $sql_query );
	$results = array();
	while ($row = mysqli_fetch_array($retval, MYSQLI_ASSOC))
	    array_push($results, $row);
  
	if ($results) {
	    echo json_encode($results);
	}

	mysqli_close($conn);
?>
