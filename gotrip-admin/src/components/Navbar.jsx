import { useNavigate } from "react-router-dom";
import { useAuth } from "../contexts/AuthContext";

export default function Navbar() {
  const { logout } = useAuth();
  const navigate = useNavigate();

  const handleLogout = async () => {
    if (confirm("Yakin ingin logout?")) {
      await logout();
      navigate("/login");
    }
  };

  return (
    <nav className="navbar">
      <h3>GOTRIP Admin</h3>
      <button className="logout-btn" onClick={handleLogout}>Logout</button>
    </nav>
  );
}
