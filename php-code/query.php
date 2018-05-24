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
	
	$cid = $_GET["cid"];//获取课程号
	//甄别是否为学生ID，若是学生ID，则打印对应学生姓名、课程开始时间、签到时间；若非学生ID，则打印所有的学生姓名、课程开始、签到时间
	if (isset($_GET["sid"])) {
		$sid = $_GET["sid"];
		$sql_query = "select a.name, start_time, checkin_time, stat from Student a, Checkin b where a.sid=b.sid and cid='$cid' and a.sid='$sid'";
	} else {
		$sql_query = "select a.name, start_time, checkin_time, stat from Student a, Checkin b where a.sid=b.sid and cid='$cid'";
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
