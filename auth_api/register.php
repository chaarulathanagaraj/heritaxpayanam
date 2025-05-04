<?php


// Database configuration
$host = 'localhost';
$db_user = 'root';
$db_password = '';
$db_name = 'auth_app';

// Create connection
$conn = mysqli_connect($host, $db_user, $db_password, $db_name);
if ($conn->connect_error) {
    http_response_code(500);
    die(json_encode(["error" => "Database connection failed"]));
}

// Get and validate input
$data = json_decode(file_get_contents('php://input'), true);

if (!isset($data['name']) || !isset($data['email']) || !isset($data['password'])) {
    http_response_code(400);
    echo json_encode(['error' => 'Missing required fields']);
    exit;
}

// Validate email format
if (!filter_var($data['email'], FILTER_VALIDATE_EMAIL)) {
    http_response_code(400);
    echo json_encode(['error' => 'Invalid email format']);
    exit;
}

// Check if email exists
$stmt = $conn->prepare("SELECT id FROM users WHERE email = ?");
$stmt->bind_param("s", $data['email']);
$stmt->execute();
$stmt->store_result();

if ($stmt->num_rows > 0) {
    http_response_code(409);
    echo json_encode(['error' => 'Email already exists']);
    exit;
}
$stmt->close();

// Hash password and create user
$password = password_hash($data['password'], PASSWORD_BCRYPT);
$stmt = $conn->prepare("INSERT INTO users (name, email, password) VALUES (?, ?, ?)");
$stmt->bind_param("sss", $data['name'], $data['email'], $password);

if ($stmt->execute()) {
    http_response_code(201);
    echo json_encode(['message' => 'User registered successfully']);
} else {
    http_response_code(500);
    echo json_encode(['error' => 'Registration failed']);
}

$stmt->close();
$conn->close();
?>