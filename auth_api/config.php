<?php
// config.php
header('Content-Type: application/json');




if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    http_response_code(200);
    exit(0);
}

$host = 'localhost';
$db_user = 'root'; // Replace with your MySQL username
$db_password = ''; // Replace with your MySQL password
$db_name = 'auth_app';

$conn = new mysqli($host, $db_user, $db_password, $db_name);
if ($conn->connect_error) {
    die(json_encode(["error" => "Connection failed: " . $conn->connect_error]));
}