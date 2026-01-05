import { createContext, useContext, useEffect, useState } from 'react'
import { login as apiLogin } from '../api/authService' 

const AuthContext = createContext(null)

export function AuthProvider({ children }){
    const [isAuthenticated, setIsAuthenticated] = useState(false)
    const [user, setUser] = useState(null)
    const [loading, setLoading] = useState(true)

    useEffect(()=>{
        const token = localStorage.getItem('authToken')
        const userData = localStorage.getItem('user')
        if (token && userData){
            try{
                const parsedUser = JSON.parse(userData);
                // Pastikan yang login hanya admin
                if (parsedUser.role === 'admin') {
                    setUser(parsedUser)
                    setIsAuthenticated(true)
                } else {
                    localStorage.removeItem('authToken')
                    localStorage.removeItem('user')
                }
            }catch(e){
                localStorage.removeItem('authToken')
                localStorage.removeItem('user')
            }
        }
        setLoading(false)
    },[])
    
    // Fungsi login menerima 3 argumen: email, password, role
    const login = async (email, password, role) => { 
        // 1. Panggil API dengan 3 argumen
        const res = await apiLogin(email, password, role) 

        const token = res.token
        const serverUser = res.user

        const actualRole = serverUser.role || serverUser.Role;

        // 2. Double check role di frontend (meskipun BE sudah memvalidasi)
        if (actualRole !== 'admin') {
            throw new Error('Akses ditolak: Hanya admin yang diperbolehkan.')
        }

        // 3. Simpan token dengan key 'authToken'
        localStorage.setItem('authToken', token)
        localStorage.setItem('user', JSON.stringify(serverUser))

        setUser(serverUser)
        setIsAuthenticated(true)
    }

    const logout = () => {
        localStorage.removeItem('authToken')
        localStorage.removeItem('user')
        setUser(null)
        setIsAuthenticated(false)
    }


    return (
        <AuthContext.Provider value={{ isAuthenticated, user, loading, login, logout }}>
        {children}
        </AuthContext.Provider>
    )
}


export function useAuth(){
    return useContext(AuthContext)
}