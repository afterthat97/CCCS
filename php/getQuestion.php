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
		$cid = $_GET["cid"];
		$sql_query = "select a.qid,a.questext,a.Achoice,a.Bchoice,a.Cchoice,a.Dchoice,a.correct from Question a,Teacher b,Course c where a.tid=b.tid and b.tid='$tid' and c.cid=a.cid and c.cid='$cid'";
	} else {
		$sid = $_GET["sid"];
		$cid = $_GET["cid"];
		$sql_query = "select a.qid,a.questext,a.Achoice,a.Bchoice,a.Cchoice,a.Dchoice,a.correct from Question a,Choose c where a.cid=c.cid and c.cid='$cid' and c.sid='$sid' ";
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
