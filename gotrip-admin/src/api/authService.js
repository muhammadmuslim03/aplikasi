const API_BASE_URL = 'http://localhost:8080'; 

export const login = async (email, password, role) => {
    const response = await fetch(`${API_BASE_URL}/auth/login`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify({ 
            email, 
            password, 
            role,
        }),
    });

    const data = await response.json();

    if (!response.ok) {
        throw new Error(data.error || 'Login gagal: Kesalahan Jaringan.'); 
    }

    return data;
};