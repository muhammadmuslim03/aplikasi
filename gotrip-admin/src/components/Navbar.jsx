import { useNavigate } from "react-router-dom";
import { useAuth } from "../contexts/AuthContext";

export default function Navbar() {
  const { logout, user } = useAuth();
  const navigate = useNavigate();

  const handleLogout = async () => {
    if (confirm("Yakin ingin logout?")) {
      await logout();
      navigate("/login", { replace: true });
    }
  };

  return (
    <nav className="navbar">
      <div className="navbar-title">
        <span className="navbar-status" aria-hidden="true" />
        <span>GOTRIP Admin</span>
      </div>

      <div className="navbar-actions">
        <div className="navbar-user">
          <strong>{user?.name || "Admin"}</strong>
          <span>{user?.email || "admin"}</span>
        </div>
        <button className="btn btn-secondary" onClick={handleLogout}>
          Keluar
        </button>
      </div>
    </nav>
  );
}
