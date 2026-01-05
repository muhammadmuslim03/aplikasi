import { Navigate } from 'react-router-dom'
import { useAuth } from '../contexts/AuthContext'

export default function ProtectedRoute({ children }){
const { isAuthenticated, user, loading } = useAuth()

if (loading) return <div style={{padding:20}}>Loading...</div>
if (!isAuthenticated) return <Navigate to="/login" replace />
if (user?.role !== 'admin') return <Navigate to="/not-authorized" replace />

return children
}