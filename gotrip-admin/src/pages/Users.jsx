import React, { useEffect, useState } from "react";
import Navbar from "../components/Navbar";
import Sidebar from "../components/Sidebar";

const API_BASE_URL = "http://localhost:8080";

const getAuthToken = () => {
  return localStorage.getItem("authToken");
};

export default function Users() {
  const [pendaki, setPendaki] = useState([]);
  const [search, setSearch] = useState("");
  const [loading, setLoading] = useState(true);

  const fetchPendaki = async () => {
    setLoading(true);
    const token = getAuthToken();

    const url =
      search.trim() === ""
        ? `${API_BASE_URL}/api/web-admin/pendaki`
        : `${API_BASE_URL}/api/web-admin/pendaki?search=${search}`;

    try {
      const response = await fetch(url, {
        headers: { Authorization: `Bearer ${token}` },
      });

      const data = await response.json();
      setPendaki(data.data || []);
    } catch (error) {
      console.error("Error fetching pendaki:", error);
    }

    setLoading(false);
  };

  const deletePendaki = async (id) => {
    if (!window.confirm("Yakin ingin menghapus pendaki ini?")) return;

    const token = getAuthToken();

    try {
      const response = await fetch(
        `${API_BASE_URL}/api/web-admin/pendaki/${id}`,
        {
          method: "DELETE",
          headers: {
            Authorization: `Bearer ${token}`,
          },
        }
      );

      if (response.ok) {
        alert("Pendaki berhasil dihapus");
        fetchPendaki();
      } else {
        alert("Gagal menghapus pendaki");
      }
    } catch (error) {
      console.error("Delete error:", error);
    }
  };

  useEffect(() => {
    fetchPendaki();
  }, [search]);

  return (
    <div className="app-layout">
      <Sidebar />

      <main className="main">
        <Navbar />

        <section className="content">
          <h1>Daftar Pendaki</h1>

          <div
            className="card"
            style={{ marginBottom: "20px", display: "flex", gap: "10px" }}
          >
            <input
              type="text"
              placeholder="Cari pendaki berdasarkan nama atau email..."
              value={search}
              onChange={(e) => setSearch(e.target.value)}
              className="search-input"
              style={{
                flex: 1,
                padding: "10px",
                borderRadius: "8px",
                border: "1px solid #ccc",
              }}
            />
          </div>

          <div className="card">
            {loading ? (
              <p>Memuat data...</p>
            ) : pendaki.length === 0 ? (
              <p>Tidak ada data pendaki.</p>
            ) : (
              <table className="data-table">
                <thead>
                  <tr>
                    <th>ID</th>
                    <th>Username</th>
                    <th>Email</th>
                    <th>Tanggal Daftar</th>
                    <th>Aksi</th>
                  </tr>
                </thead>

                <tbody>
                  {pendaki.map((item) => (
                    <tr key={item.id}>
                      <td>{item.id}</td>
                      <td>{item.username}</td>
                      <td>{item.email}</td>
                      <td>
                        {new Date(item.created_at).toLocaleDateString("id-ID")}
                      </td>
                      <td>
                        <button
                          onClick={() => deletePendaki(item.id)}
                          style={{
                            background: "red",
                            padding: "6px 12px",
                            borderRadius: "6px",
                            color: "white",
                            border: "none",
                            cursor: "pointer",
                          }}
                        >
                          Hapus
                        </button>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            )}
          </div>
        </section>
      </main>
    </div>
  );
}
