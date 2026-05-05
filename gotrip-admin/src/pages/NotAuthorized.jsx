import { Link } from "react-router-dom";
import { useAuth } from "../contexts/AuthContext";

export default function NotAuthorized() {
  const { logout } = useAuth();

  return (
    <div className="page-center">
      <div className="card auth-card">
        <h2>Akses Ditolak</h2>
        <p>Akun ini tidak memiliki role admin.</p>
        <Link className="btn" to="/login" onClick={logout}>
          Kembali ke Login
        </Link>
      </div>
    </div>
  );
}
