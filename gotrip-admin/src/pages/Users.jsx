import { useCallback, useEffect, useMemo, useState } from "react";
import AdminLayout from "../components/AdminLayout";
import api, { getApiErrorMessage } from "../api/api";

const formatDate = (dateString) => {
  if (!dateString) return "-";

  const date = new Date(dateString);
  if (Number.isNaN(date.getTime())) return "-";

  return new Intl.DateTimeFormat("id-ID", {
    day: "2-digit",
    month: "short",
    year: "numeric",
  }).format(date);
};

const formatDateTime = (dateString) => {
  if (!dateString) return "-";

  const date = new Date(dateString);
  if (Number.isNaN(date.getTime())) return "-";

  return new Intl.DateTimeFormat("id-ID", {
    day: "2-digit",
    month: "short",
    year: "numeric",
    hour: "2-digit",
    minute: "2-digit",
  }).format(date);
};

const getUserId = (user) => user?.id ?? user?.ID;
const getUserName = (user) => user?.name || user?.Name || "-";
const getUserEmail = (user) => user?.email || user?.Email || "-";
const getUserPhone = (user) => user?.phone || user?.Phone || "-";
const getUserNik = (user) => user?.nik || user?.NIK || "-";
const getUserRole = (user) => user?.role || user?.Role || "-";
const getUserCreatedAt = (user) => user?.created_at ?? user?.CreatedAt;
const getUserCheckIn = (user) => user?.check_in ?? user?.CheckIn ?? false;
const getUserCheckOut = (user) => user?.check_out ?? user?.CheckOut ?? false;
const getUserCheckInAt = (user) => user?.check_in_at ?? user?.CheckInAt;
const getUserCheckOutAt = (user) => user?.check_out_at ?? user?.CheckOutAt;

function StatusText({ active }) {
  return (
    <span className={`status-badge ${active ? "status-success" : "status-muted"}`}>
      {active ? "Ya" : "Belum"}
    </span>
  );
}

export default function Users() {
  const [pendaki, setPendaki] = useState([]);
  const [search, setSearch] = useState("");
  const [debouncedSearch, setDebouncedSearch] = useState("");
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");
  const [deletingId, setDeletingId] = useState(null);
  const [notice, setNotice] = useState("");

  const fetchPendaki = useCallback(async () => {
    setLoading(true);
    setError("");

    try {
      const response = await api.get("/api/web-admin/pendaki", {
        params: debouncedSearch.trim()
          ? { search: debouncedSearch.trim() }
          : undefined,
      });

      setPendaki(Array.isArray(response.data?.data) ? response.data.data : []);
    } catch (error) {
      setError(getApiErrorMessage(error, "Gagal memuat data pendaki"));
    } finally {
      setLoading(false);
    }
  }, [debouncedSearch]);

  const deletePendaki = async (id) => {
    if (!id) {
      setError("ID pendaki tidak ditemukan dari respons server");
      return;
    }

    if (!window.confirm("Yakin ingin menghapus pendaki ini?")) return;

    setDeletingId(id);
    setNotice("");
    setError("");
    try {
      await api.delete(`/api/web-admin/pendaki/${id}`);
      setNotice("Pendaki berhasil dihapus");
      await fetchPendaki();
    } catch (error) {
      setError(getApiErrorMessage(error, "Gagal menghapus pendaki"));
    } finally {
      setDeletingId(null);
    }
  };

  useEffect(() => {
    const timer = window.setTimeout(() => {
      setDebouncedSearch(search);
    }, 300);

    return () => window.clearTimeout(timer);
  }, [search]);

  useEffect(() => {
    fetchPendaki();
  }, [fetchPendaki]);

  const totalPhone = useMemo(
    () => pendaki.filter((item) => getUserPhone(item) !== "-").length,
    [pendaki]
  );

  const totalCheckedIn = useMemo(
    () => pendaki.filter((item) => getUserCheckIn(item)).length,
    [pendaki]
  );

  return (
    <AdminLayout
      title="Pendaki"
      subtitle="Data akun pendaki yang terdaftar di aplikasi."
      actions={
        <button className="btn btn-secondary" onClick={fetchPendaki}>
          Refresh
        </button>
      }
    >
      {error && (
        <div className="alert alert-danger">
          <span>{error}</span>
          <button className="btn btn-text" onClick={fetchPendaki}>
            Coba lagi
          </button>
        </div>
      )}

      {notice && <div className="alert alert-success">{notice}</div>}

      <div className="summary-grid users-summary">
        <div className="stat-card">
          <span>Total Pendaki</span>
          <strong>{pendaki.length}</strong>
          <small>Hasil sesuai pencarian</small>
        </div>
        <div className="stat-card stat-card-hikers">
          <span>Kontak Tersedia</span>
          <strong>{totalPhone}</strong>
          <small>Nomor telepon terisi</small>
        </div>
        <div className="stat-card stat-card-active">
          <span>Sedang Check-in</span>
          <strong>{totalCheckedIn}</strong>
          <small>Status dari scan barcode</small>
        </div>
      </div>

      <div className="toolbar">
        <input
          type="search"
          placeholder="Cari nama atau email..."
          value={search}
          onChange={(e) => setSearch(e.target.value)}
          className="search-input"
        />
      </div>

      <div className="card table-card">
        {loading ? (
          <div className="empty-state">Memuat pendaki...</div>
        ) : pendaki.length === 0 ? (
          <div className="empty-state">Tidak ada data pendaki</div>
        ) : (
          <div className="table-responsive">
            <table className="data-table">
              <thead>
                <tr>
                  <th>ID</th>
                  <th>Nama</th>
                  <th>Email</th>
                  <th>Telepon</th>
                  <th>NIK</th>
                  <th>Check-in</th>
                  <th>Check-out</th>
                  <th>Daftar</th>
                  <th>Aksi</th>
                </tr>
              </thead>

              <tbody>
                {pendaki.map((item) => (
                  <tr key={getUserId(item)}>
                    <td className="mono">{getUserId(item)}</td>
                    <td>
                      <strong>{getUserName(item)}</strong>
                      <span className="table-subtext">{getUserRole(item)}</span>
                    </td>
                    <td>{getUserEmail(item)}</td>
                    <td>{getUserPhone(item)}</td>
                    <td className="mono">{getUserNik(item)}</td>
                    <td>
                      <StatusText active={getUserCheckIn(item)} />
                      <span className="table-subtext">
                        {formatDateTime(getUserCheckInAt(item))}
                      </span>
                    </td>
                    <td>
                      <StatusText active={getUserCheckOut(item)} />
                      <span className="table-subtext">
                        {formatDateTime(getUserCheckOutAt(item))}
                      </span>
                    </td>
                    <td>{formatDate(getUserCreatedAt(item))}</td>
                    <td>
                      <button
                        onClick={() => deletePendaki(getUserId(item))}
                        className="btn btn-danger btn-sm"
                        disabled={deletingId === getUserId(item)}
                      >
                        {deletingId === getUserId(item) ? "Menghapus..." : "Hapus"}
                      </button>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </div>
    </AdminLayout>
  );
}
