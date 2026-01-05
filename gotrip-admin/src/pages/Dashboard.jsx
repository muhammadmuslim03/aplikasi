import {
  AreaChart,
  Area,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  ResponsiveContainer,
  LineChart,
  Line,
} from "recharts";
import React, { useState, useEffect } from "react";
import Navbar from "../components/Navbar";
import Sidebar from "../components/Sidebar";

const API_BASE_URL = "http://localhost:8080";

const formatRupiah = (number) => {
  return new Intl.NumberFormat("id-ID", {
    style: "currency",
    currency: "IDR",
    minimumFractionDigits: 0,
  }).format(number);
};

const getAuthToken = () => {
  return localStorage.getItem("authToken");
};

export default function Dashboard() {
  const [summary, setSummary] = useState({
    total_pendapatan: 0,
    total_booking: 0,
    total_pendaki: 0,
    total_pending: 0,
    total_pendaki_booking: 0,
  });
  const [chartData, setChartData] = useState({
    pendapatan: [],
    pendaki: [],
  });
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    fetchDashboardData();
  }, []);

  const fetchDashboardData = async () => {
    setLoading(true);
    const token = getAuthToken();

    // Cek Token
    if (!token) {
      setError("Token otorisasi tidak ditemukan. Silakan login kembali.");
      setLoading(false);
      return;
    }

    const headers = {
      Authorization: `Bearer ${token}`,
      "Content-Type": "application/json",
    };

    try {
      const summaryResponse = await fetch(
        `${API_BASE_URL}/api/web-admin/dashboard`,
        { headers }
      );

      if (summaryResponse.status === 401 || summaryResponse.status === 403) {
        throw new Error("Sesi habis atau tidak terotorisasi. (401/403)");
      }
      if (!summaryResponse.ok) {
        throw new Error(
          "Gagal mengambil data ringkasan. Status: " + summaryResponse.status
        );
      }

      const summaryJson = await summaryResponse.json();
      setSummary(summaryJson);

      const pendapatanResponse = await fetch(
        `${API_BASE_URL}/api/web-admin/chart/pendapatan`,
        { headers }
      );
      const pendapatanJson = await pendapatanResponse.json();

      const pendakiResponse = await fetch(
        `${API_BASE_URL}/api/web-admin/chart/pendaki`,
        { headers }
      );
      const pendakiJson = await pendakiResponse.json();

      setChartData({
        pendapatan: pendapatanJson.data,
        pendaki: pendakiJson.data,
      });
    } catch (err) {
      console.error("Error fetching dashboard data:", err);
      setError(err.message);
    } finally {
      setLoading(false);
    }
  };

  if (loading)
    return <p style={{ padding: "20px" }}>Memuat data Dashboard...</p>;
  if (error)
    return (
      <p style={{ color: "red", padding: "20px" }}>
        Error: {error}. Pastikan BE berjalan di {API_BASE_URL} dan Anda sudah
        login.
      </p>
    );

  return (
    <div className="app-layout">
      <Sidebar />

      <main className="main">
        <Navbar />

        <section className="content">
          <h1>Selamat Datang di Dashboard Admin</h1>

          <div className="summary-grid">
            <div className="card small">
              Total Pendapatan
              <br />
              <strong>{formatRupiah(summary.total_pendapatan)}</strong>
            </div>
            <div className="card small">
              Total Booking
              <br />
              <strong>{summary.total_booking}</strong>
            </div>
            <div className="card small">
              Total Pendaki (Org)
              <br />
              <strong>{summary.total_pendaki_booking}</strong>
            </div>
            <div className="card small status-pending">
              Pending Konfirmasi
              <br />
              <strong>{summary.total_pending}</strong>
            </div>
          </div>

          <div
            style={{
              marginTop: 30,
              display: "grid",
              gridTemplateColumns: "1fr 1fr",
              gap: "20px",
            }}
          >
            <div className="card large">
              <h2>Statistik Pendapatan Bulanan</h2>

              <ResponsiveContainer width="100%" height={250}>
                <AreaChart data={chartData.pendapatan}>
                  <defs>
                    <linearGradient
                      id="colorPendapatan"
                      x1="0"
                      y1="0"
                      x2="0"
                      y2="1"
                    >
                      <stop offset="5%" stopColor="#4CAF50" stopOpacity={0.8} />
                      <stop offset="95%" stopColor="#4CAF50" stopOpacity={0} />
                    </linearGradient>
                  </defs>

                  <CartesianGrid strokeDasharray="3 3" />
                  <XAxis dataKey="bulan" />
                  <YAxis />
                  <Tooltip formatter={(value) => formatRupiah(value)} />

                  <Area
                    type="monotone"
                    dataKey="total"
                    stroke="#4CAF50"
                    fillOpacity={1}
                    fill="url(#colorPendapatan)"
                  />
                </AreaChart>
              </ResponsiveContainer>
            </div>

            <div className="card large">
              <h2>Statistik Pendaftaran Pendaki</h2>

              <ResponsiveContainer width="100%" height={250}>
                <LineChart data={chartData.pendaki}>
                  <CartesianGrid strokeDasharray="3 3" />
                  <XAxis dataKey="bulan" />
                  <YAxis />
                  <Tooltip />

                  <Line
                    type="monotone"
                    dataKey="total"
                    stroke="#2196F3"
                    strokeWidth={3}
                    dot={{ r: 4 }}
                    activeDot={{ r: 6 }}
                  />
                </LineChart>
              </ResponsiveContainer>
            </div>
          </div>
        </section>
      </main>
    </div>
  );
}
