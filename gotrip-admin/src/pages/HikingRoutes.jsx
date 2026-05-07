import { useCallback, useEffect, useMemo, useState } from "react";
import AdminLayout from "../components/AdminLayout";
import api, { getApiErrorMessage } from "../api/api";

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

function RouteStatusBadge({ isOpen }) {
  return (
    <span className={`status-badge ${isOpen ? "status-success" : "status-danger"}`}>
      {isOpen ? "Terbuka" : "Ditutup"}
    </span>
  );
}

export default function HikingRoutes() {
  const [routes, setRoutes] = useState([]);
  const [selectedRoute, setSelectedRoute] = useState(null);
  const [closedReason, setClosedReason] = useState("");
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");
  const [notice, setNotice] = useState("");
  const [actionError, setActionError] = useState("");
  const [updatingId, setUpdatingId] = useState(null);

  const fetchRoutes = useCallback(async () => {
    setLoading(true);
    setError("");

    try {
      const response = await api.get("/api/web-admin/hiking-routes");
      setRoutes(Array.isArray(response.data?.data) ? response.data.data : []);
    } catch (err) {
      setError(getApiErrorMessage(err, "Gagal memuat data jalur pendakian"));
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    fetchRoutes();
  }, [fetchRoutes]);

  const stats = useMemo(
    () => ({
      total: routes.length,
      open: routes.filter((route) => route.is_open).length,
      closed: routes.filter((route) => !route.is_open).length,
    }),
    [routes]
  );

  const closeModal = () => {
    setSelectedRoute(null);
    setClosedReason("");
    setActionError("");
  };

  const updateRouteStatus = async (route, isOpen, reason = "") => {
    if (!route?.id) return;

    setUpdatingId(route.id);
    setError("");
    setNotice("");
    setActionError("");

    try {
      const response = await api.patch(
        `/api/web-admin/hiking-routes/${route.id}/status`,
        {
          is_open: isOpen,
          closed_reason: reason.trim(),
        }
      );

      const updatedRoute = response.data?.data;

      setRoutes((currentRoutes) =>
        currentRoutes.map((item) =>
          item.id === route.id ? { ...item, ...updatedRoute } : item
        )
      );
      setNotice(`${route.route_name} berhasil ${isOpen ? "dibuka" : "ditutup"}`);

      if (!isOpen) closeModal();
    } catch (err) {
      const message = getApiErrorMessage(err, "Gagal memperbarui status jalur");

      if (selectedRoute) {
        setActionError(message);
      } else {
        setError(message);
      }
    } finally {
      setUpdatingId(null);
    }
  };

  const openCloseModal = (route) => {
    setSelectedRoute(route);
    setClosedReason(route.closed_reason || "");
    setActionError("");
  };

  return (
    <AdminLayout
      title="Jalur Pendakian"
      subtitle="Atur status operasional jalur yang bisa dipesan pendaki."
      actions={
        <button className="btn btn-secondary" onClick={fetchRoutes} disabled={loading}>
          Refresh
        </button>
      }
    >
      {error && (
        <div className="alert alert-danger">
          <span>{error}</span>
          <button className="btn btn-text" onClick={fetchRoutes}>
            Coba lagi
          </button>
        </div>
      )}

      {notice && <div className="alert alert-success">{notice}</div>}

      <div className="summary-grid routes-summary">
        <div className="stat-card">
          <span>Total Jalur</span>
          <strong>{stats.total}</strong>
          <small>Terdaftar di sistem</small>
        </div>
        <div className="stat-card stat-card-active">
          <span>Terbuka</span>
          <strong>{stats.open}</strong>
          <small>Bisa menerima booking</small>
        </div>
        <div className="stat-card stat-card-pending">
          <span>Ditutup</span>
          <strong>{stats.closed}</strong>
          <small>Booking baru diblokir</small>
        </div>
      </div>

      <div className="card table-card">
        {loading ? (
          <div className="empty-state">Memuat jalur pendakian...</div>
        ) : routes.length === 0 ? (
          <div className="empty-state">Belum ada data jalur pendakian</div>
        ) : (
          <div className="table-responsive">
            <table className="data-table routes-table">
              <thead>
                <tr>
                  <th>ID</th>
                  <th>Jalur</th>
                  <th>Status</th>
                  <th>Catatan</th>
                  <th>Diperbarui</th>
                  <th>Aksi</th>
                </tr>
              </thead>

              <tbody>
                {routes.map((route) => (
                  <tr key={route.id}>
                    <td className="mono">{route.id}</td>
                    <td>
                      <strong>{route.route_name || "-"}</strong>
                      {route.description && (
                        <span className="table-subtext">{route.description}</span>
                      )}
                    </td>
                    <td>
                      <RouteStatusBadge isOpen={route.is_open} />
                    </td>
                    <td className="route-note">{route.closed_reason || "-"}</td>
                    <td>{formatDateTime(route.updated_at)}</td>
                    <td>
                      {route.is_open ? (
                        <button
                          className="btn btn-danger btn-sm"
                          onClick={() => openCloseModal(route)}
                          disabled={updatingId === route.id}
                        >
                          Tutup
                        </button>
                      ) : (
                        <button
                          className="btn btn-success btn-sm"
                          onClick={() => updateRouteStatus(route, true)}
                          disabled={updatingId === route.id}
                        >
                          {updatingId === route.id ? "Membuka..." : "Buka"}
                        </button>
                      )}
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </div>

      {selectedRoute && (
        <div className="modal-overlay" role="dialog" aria-modal="true">
          <div className="modal-box route-modal">
            <div className="modal-header">
              <div>
                <p className="eyebrow">Status Jalur</p>
                <h2>Tutup Jalur Pendakian</h2>
              </div>
              <button
                className="icon-button"
                onClick={closeModal}
                aria-label="Tutup modal"
              >
                x
              </button>
            </div>

            <div className="ticket-detail-grid">
              <div>
                <span>Jalur</span>
                <strong>{selectedRoute.route_name || "-"}</strong>
              </div>
              <div>
                <span>Status Saat Ini</span>
                <RouteStatusBadge isOpen={selectedRoute.is_open} />
              </div>
            </div>

            <label className="field-label" htmlFor="closed-reason">
              Catatan penutupan
            </label>
            <textarea
              id="closed-reason"
              className="reject-textarea"
              placeholder="Contoh: cuaca buruk, perbaikan jalur, atau kuota penuh"
              value={closedReason}
              onChange={(event) => setClosedReason(event.target.value)}
            />

            {actionError && (
              <div className="alert alert-danger compact">{actionError}</div>
            )}

            <div className="modal-actions">
              <button
                className="btn btn-danger"
                onClick={() =>
                  updateRouteStatus(selectedRoute, false, closedReason)
                }
                disabled={updatingId === selectedRoute.id}
              >
                {updatingId === selectedRoute.id ? "Menutup..." : "Tutup jalur"}
              </button>
              <button className="btn btn-secondary" onClick={closeModal}>
                Batal
              </button>
            </div>
          </div>
        </div>
      )}
    </AdminLayout>
  );
}
