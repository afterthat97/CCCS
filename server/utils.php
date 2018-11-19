<?php

function encode_result($code, $info) {
    $result['code'] = $code;
    $result['info'] = $info;
    return json_encode($result);
}

function connect_db($dbhost, $dbuser, $dbpass, $dbname) {
    $conn = mysqli_connect($dbhost, $dbuser, $dbpass, $dbname);
    if (mysqli_connect_errno())
        die(encode_result(1, "Failed to connect to MySQL: " . mysqli_connect_error()));
    return $conn;
}

function close_db($conn) {
    mysqli_close($conn);
}

function get_current_time($conn) {
	$query = "select NOW() as cnt_time";
	$retval = mysqli_query($conn, $query);
	$row = mysqli_fetch_array($retval, MYSQLI_ASSOC);
	return $row['cnt_time'];
}

function get_time_diff($conn, $t1, $t2) {
    $query = "select time_to_sec(timediff('$t1', '$t2')) as diff";
	$retval = mysqli_query($conn, $query);
	$row = mysqli_fetch_array($retval, MYSQLI_ASSOC);
	return $row['diff'];
}

function get_distance($latitude1, $longitude1, $latitude2, $longitude2) {
    $latitude_diff = $latitude2 - $latitude1;
    $longitude_diff = $longitude2 - $longitude1;
    
    $pi = 3.14159268979;
    $r = 6378137.0;
    $latitude_diff = sin($latitude_diff * $pi / 180.0) * $r;
    $longitude_diff = sin($longitude_diff * $pi / 180.0) * $r;

    return (int)sqrt($latitude_diff * $latitude_diff + $longitude_diff * $longitude_diff);
}

function new_user($conn, $username, $password, $type, $gender, $realname) {
    if (validate_user($conn, $username, $password, $type) != null)
        return false;
    $realname = urlencode($realname);
    $query = "insert into $type ".
        "(username, password, realname, gender)".
        "values".
        "('$username', '$password', '$realname', '$gender')";
	return mysqli_query($conn, $query);
}

function validate_user($conn, $username, $password, $type) {
    $query = "select * from $type ".
        "where username = '$username'";
    $retval = mysqli_query($conn, $query);
    $row = mysqli_fetch_array($retval, MYSQLI_ASSOC);
    if ($row && $row['password'] == $password)
        return $row;
    else
        return null;
}

function get_student_by_id($conn, $sid) {
    $query = "select * from Student ".
        "where sid = $sid";
    $retval = mysqli_query($conn, $query);
    $row = mysqli_fetch_array($retval, MYSQLI_ASSOC);
    unset($row['password']);
    return $row;
}

function get_teacher_by_id($conn, $tid) {
    $query = "select * from Teacher ".
        "where tid = $tid";
    $retval = mysqli_query($conn, $query);
    $row = mysqli_fetch_array($retval, MYSQLI_ASSOC);
    unset($row['password']);
    return $row;
}

function new_course($conn, $name, $tid, $credit, $place) {
    if (get_course_by_name($conn, $name, $tid, $place) != null)
        return false;
    $name = urlencode($name);
    $place = urlencode($place);
    $query = "insert into Course ".
            "(tid, name, credit, place) ".
            "values ".
            "($tid, '$name', $credit, '$place')";
    return mysqli_query($conn, $query);
}

function select_course($conn, $sid, $cid) {
    if (get_selection_record($conn, $sid, $cid))
        return false;
    $query = "insert into StudentCourse ".
        "(sid, cid) ".
        "values ".
        "($sid, $cid)";
    return mysqli_query($conn, $query);
}

function get_selection_record($conn, $sid, $cid) {
    $query = "select * from StudentCourse ".
        "where sid = $sid and cid = $cid";
	$retval = mysqli_query($conn, $query);
    return mysqli_fetch_array($retval, MYSQLI_ASSOC);
}

function get_selection_records_by_sid($conn, $sid) {
    $query = "select * from StudentCourse ".
        "where sid = $sid";
	$retval = mysqli_query($conn, $query);
    $selectionlist = array();
    while ($row = mysqli_fetch_array($retval, MYSQLI_ASSOC))
        array_push($selectionlist, $row);
    return $selectionlist;
}

function get_selection_records_by_cid($conn, $cid) {
    $query = "select * from StudentCourse ".
        "where cid = $cid";
	$retval = mysqli_query($conn, $query);
    $selectionlist = array();
    while ($row = mysqli_fetch_array($retval, MYSQLI_ASSOC))
        array_push($selectionlist, $row);
    return $selectionlist;
}

function get_course_by_name($conn, $name, $tid) {
    $query = "select * from Course ".
        "where name = '$name' and tid = $tid";
	$retval = mysqli_query($conn, $query);
    return mysqli_fetch_array($retval, MYSQLI_ASSOC);
}

function get_course_by_id($conn, $cid) {
    $query = "select * from Course ".
        "where cid = $cid";
	$retval = mysqli_query($conn, $query);
    return mysqli_fetch_array($retval, MYSQLI_ASSOC);
}

function get_courselist_all($conn) {
    $query = "select * from Course";
	$retval = mysqli_query($conn, $query);
    $courselist = array();
    while ($row = mysqli_fetch_array($retval, MYSQLI_ASSOC))
        array_push($courselist, $row);
    return $courselist;
}

function get_courselist_by_tid($conn, $tid) {
    $query = "select * from Course ".
        "where tid = $tid";
	$retval = mysqli_query($conn, $query);
    $courselist = array();
    while ($row = mysqli_fetch_array($retval, MYSQLI_ASSOC))
        array_push($courselist, $row);
    return $courselist;
}

function get_courselist_by_sid($conn, $sid) {
    $query = "select a.* from Course a, StudentCourse b ".
        "where a.cid = b.cid and b.sid = $sid";
	$retval = mysqli_query($conn, $query);
    $courselist = array();
    while ($row = mysqli_fetch_array($retval, MYSQLI_ASSOC))
        array_push($courselist, $row);
    return $courselist;
}

function new_lesson($conn, $cid, $latitude, $longitude) {
    $query = "insert into Lesson ".
            "(cid, start_time, latitude, longitude) ".
            "values ".
            "($cid, NOW(), $latitude, $longitude)";
    return mysqli_query($conn, $query);
}

function end_lesson($conn, $lid) {
    $lesson = get_lesson_by_lid($conn, $lid);
    if ($lesson["end_time"] != null)
        return false;
    $query = "update Lesson set ".
			"end_time = NOW() ".
			"where lid = $lid";
    return mysqli_query($conn, $query);
}

function get_lesson_by_lid($conn, $lid) {
    $query = "select * from Lesson ".
        "where lid = $lid";
	$retval = mysqli_query($conn, $query);
    return mysqli_fetch_array($retval, MYSQLI_ASSOC);
}

function get_lessonlist_by_cid($conn, $cid) {
    $query = "select * from Lesson ".
        "where cid = $cid order by start_time desc;";
	$retval = mysqli_query($conn, $query);
    $lessonlist = array();
    while ($row = mysqli_fetch_array($retval, MYSQLI_ASSOC))
        array_push($lessonlist, $row);
    return $lessonlist;
}

function new_checkin_record($conn, $sid, $lid, $checkin_time, $status) {
    if (get_checkin_record($conn, $sid, $lid))
        return false;
    if ($checkin_time)
        $query = "insert into StudentLesson ".
                "(sid, lid, checkin_time, status) ".
                "values ".
                "($sid, $lid, '$checkin_time', '$status')";
    else
        $query = "insert into StudentLesson ".
                "(sid, lid, status) ".
                "values ".
                "($sid, $lid, '$status')";
    return mysqli_query($conn, $query);
}

function get_checkin_record($conn, $sid, $lid) {
    $query = "select * from StudentLesson ".
        "where sid = $sid and lid = $lid";
	$retval = mysqli_query($conn, $query);
    return mysqli_fetch_array($retval, MYSQLI_ASSOC);
}

function get_checkin_records_by_sid_and_cid($conn, $sid, $cid) {
    $query = "select b.* from Lesson a, StudentLesson b ".
        "where a.lid = b.lid and a.cid = $cid and b.sid = $sid";
	$retval = mysqli_query($conn, $query);
    $checkin_records = array();
    while ($row = mysqli_fetch_array($retval, MYSQLI_ASSOC))
        array_push($checkin_records, $row);
    return $checkin_records;
}

function get_checkin_records_by_cid($conn, $cid) {
    $query = "select b.* from Lesson a, StudentLesson b ".
        "where a.lid = b.lid and a.cid = $cid";
	$retval = mysqli_query($conn, $query);
    $checkin_records = array();
    while ($row = mysqli_fetch_array($retval, MYSQLI_ASSOC))
        array_push($checkin_records, $row);
    return $checkin_records;
}

?>
