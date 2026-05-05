import axios from "axios";

export const API_BASE_URL =
  import.meta.env.VITE_API_BASE_URL || "http://localhost:8080";

const api = axios.create({
  baseURL: API_BASE_URL,
  timeout: 15000,
});

api.interceptors.request.use((config) => {
  const token = localStorage.getItem("authToken");

  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }

  return config;
});

export function getApiErrorMessage(error, fallback = "Terjadi kesalahan") {
  const data = error?.response?.data;

  if (typeof data === "string" && data.trim()) return data;
  if (data?.message) return data.message;
  if (data?.error) return data.error;
  if (error?.code === "ECONNABORTED") return "Koneksi ke server terlalu lama";
  if (error?.message === "Network Error") return "Server tidak dapat dihubungi";

  return fallback;
}

export function getProofImageUrl(proofImagePath) {
  if (!proofImagePath) return "";

  const cleanPath = String(proofImagePath).replace(/^\/+/, "");

  if (/^https?:\/\//i.test(cleanPath)) return cleanPath;

  return cleanPath.startsWith("uploads/")
    ? `${API_BASE_URL}/${cleanPath}`
    : `${API_BASE_URL}/uploads/${cleanPath}`;
}

export default api;
