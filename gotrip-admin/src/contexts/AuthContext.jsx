import {
  createContext,
  useCallback,
  useContext,
  useEffect,
  useMemo,
  useState,
} from "react";
import { login as apiLogin } from "../api/authService";

const AuthContext = createContext(null);
const TOKEN_KEY = "authToken";
const USER_KEY = "user";

function normalizeUser(user) {
  if (!user) return null;

  return {
    ...user,
    id: user.id ?? user.ID,
    name: user.name ?? user.Name ?? "Admin",
    email: user.email ?? user.Email ?? "",
    role: user.role ?? user.Role,
  };
}

function clearSession() {
  localStorage.removeItem(TOKEN_KEY);
  localStorage.removeItem(USER_KEY);
}

export function AuthProvider({ children }) {
  const [isAuthenticated, setIsAuthenticated] = useState(false);
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const token = localStorage.getItem(TOKEN_KEY);
    const userData = localStorage.getItem(USER_KEY);

    if (token && userData) {
      try {
        const parsedUser = normalizeUser(JSON.parse(userData));

        if (parsedUser?.role === "admin") {
          setUser(parsedUser);
          setIsAuthenticated(true);
        } else {
          clearSession();
        }
      } catch (e) {
        clearSession();
      }
    }

    setLoading(false);
  }, []);

  const login = useCallback(async (email, password) => {
    const res = await apiLogin(email.trim(), password);

    const token = res.token || res.access_token || res.accessToken;
    const serverUser = normalizeUser(res.user);

    if (!token) {
      throw new Error("Token login tidak dikirim server");
    }

    if (!serverUser || serverUser.role !== "admin") {
      throw new Error("Akses ditolak: hanya admin");
    }

    localStorage.setItem(TOKEN_KEY, token);
    localStorage.setItem(USER_KEY, JSON.stringify(serverUser));

    setUser(serverUser);
    setIsAuthenticated(true);

    return res;
  }, []);

  const logout = useCallback(() => {
    clearSession();
    setUser(null);
    setIsAuthenticated(false);
  }, []);

  const value = useMemo(
    () => ({ isAuthenticated, user, loading, login, logout }),
    [isAuthenticated, user, loading, login, logout]
  );

  return (
    <AuthContext.Provider value={value}>
      {children}
    </AuthContext.Provider>
  );
}

export function useAuth() {
  const context = useContext(AuthContext);

  if (!context) {
    throw new Error("useAuth harus dipakai di dalam AuthProvider");
  }

  return context;
}
