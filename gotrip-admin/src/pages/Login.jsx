import { useEffect, useState } from "react";
import { useAuth } from "../contexts/AuthContext";
import { useNavigate } from "react-router-dom";

export default function Login() {
  const { isAuthenticated, loading: sessionLoading, login } = useAuth();
  const navigate = useNavigate();

  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState("");

  useEffect(() => {
    if (!sessionLoading && isAuthenticated) {
      navigate("/", { replace: true });
    }
  }, [isAuthenticated, navigate, sessionLoading]);

  const submit = async (e) => {
    e.preventDefault();
    setError("");
    setLoading(true);

    try {
      await login(email, password);

      navigate("/", { replace: true });
    } catch (err) {
      setError(err.message || "Login gagal");
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="login-page">
      <section className="login-panel">
        <div className="brand-mark large">GT</div>
        <p className="eyebrow">GOTRIP Admin</p>
        <h1>Panel Operasional</h1>
        <p>
          Pantau tiket pendakian, verifikasi pembayaran, dan kelola data
          pendaki.
        </p>
      </section>

      <div className="card login-card">
        <h2>Masuk Admin</h2>

        {error && <div className="alert alert-danger">{error}</div>}

        <form onSubmit={submit}>
          <label htmlFor="email">Email</label>
          <input
            id="email"
            value={email}
            onChange={(e) => setEmail(e.target.value)}
            type="email"
            autoComplete="email"
            required
          />

          <label htmlFor="password">Password</label>
          <input
            id="password"
            value={password}
            onChange={(e) => setPassword(e.target.value)}
            type="password"
            autoComplete="current-password"
            required
          />

          <button className="btn" disabled={loading || sessionLoading}>
            {loading ? "Memproses..." : "Login"}
          </button>
        </form>
      </div>
    </div>
  );
}
