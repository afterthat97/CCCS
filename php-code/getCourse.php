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
	
	//甄别是教师ID还是学生ID，对于教师，是打印所有自己所教授的课程信息；对于学生，是打印所有自己选修的课程信息和相应老师
	if (isset($_GET["tid"])) {
		$tid = $_GET["tid"];
		$sql_query = "select a.*, b.name as teacher from Course a, Teacher b where a.tid=b.tid and a.tid='$tid'";
		//若是教师，则选取匹配相应教师ID的课程表的全部项与教师表的姓名
	} else {
		$sid = $_GET["sid"];
		$sql_query = "select b.*, a.name as teacher from Teacher a, Course b, Choose c where a.tid=b.tid and b.cid=c.cid and sid='$sid'";
		//若是学生，则选取匹配相应学生ID的课程表的全部项与教师表的姓名
	}
	
	$retval = mysqli_query( $conn, $sql_query );
	$results = array();//新建数组
	while ($row = mysqli_fetch_array($retval, MYSQLI_ASSOC))
	    array_push($results, $row);//插入查询到的元素
  
	if ($results) {
	    echo json_encode($results);//打印数组
	}

	mysqli_close($conn);
?>
