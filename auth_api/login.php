<?php

header('Access-Control-Allow-Methods: POST, GET, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

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
if (basename($_SERVER['SCRIPT_FILENAME']) == 'login.php') {
    // Get the posted data
    $data = json_decode(file_get_contents('php://input'), true);

    if (isset($data['email']) && isset($data['password'])) {
        $email = $conn->real_escape_string($data['email']);
        $password = $data['password'];
        
        // Get user from database
        $query = "SELECT * FROM users WHERE email = '$email'";
        $result = $conn->query($query);
        
        if ($result->num_rows > 0) {
            $user = $result->fetch_assoc();
            
            // Verify password
            if (password_verify($password, $user['password'])) {
                // Password is correct
                echo json_encode([
                    'message' => 'Login successful',
                    'user' => [
                        'id' => $user['id'],
                        'name' => $user['name'],
                        'email' => $user['email']
                    ]
                ]);
            } else {
                http_response_code(401);
                echo json_encode(['error' => 'Invalid credentials']);
            }
        } else {
            http_response_code(401);
            echo json_encode(['error' => 'Invalid credentials']);
        }
    } else {
        http_response_code(400);
        echo json_encode(['error' => 'Missing required fields']);
    }
}
