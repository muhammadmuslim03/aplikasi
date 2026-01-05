package models

// === AUTH REQUESTS ===
type LoginRequest struct {
    Email    string `json:"email" binding:"required,email"`
    Password string `json:"password" binding:"required"`
    Role     string `json:"role"`
}

type RegisterRequest struct {
    Username        string `json:"username" binding:"required"`
    Email           string `json:"email" binding:"required,email"`
    Password        string `json:"password" binding:"required,min=6"`
    ConfirmPassword string `json:"confirm_password" binding:"required"`
    Role            string `json:"role" `
}

// === AUTH RESPONSE ===
type AuthResponse struct {
    Token string       `json:"token"`
    User  UserResponse `json:"user"`
}