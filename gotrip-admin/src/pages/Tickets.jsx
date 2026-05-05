import { useCallback, useEffect, useMemo, useState } from "react";
import AdminLayout from "../components/AdminLayout";
import api, {
  getApiErrorMessage,
  getProofImageUrl,
} from "../api/api";

const statusMeta = {
  all: { label: "Semua" },
  pending: { label: "Belum bayar", className: "status-pending" },
  waiting_verification: {
    label: "Verifikasi",
    className: "status-warning",
  },
  paid: { label: "Terbayar", className: "status-success" },
  checked_in: { label: "Check-in", className: "status-info" },
  checked_out: { label: "Selesai", className: "status-muted" },
  cancelled: { label: "Ditolak", className: "status-danger" },
};

const statusOptions = Object.keys(statusMeta);

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

const formatRupiah = (num) =>
  new Intl.NumberFormat("id-ID", {
    style: "currency",
    currency: "IDR",
    minimumFractionDigits: 0,
  }).format(num || 0);

function StatusBadge({ status }) {
  const meta = statusMeta[status] || { label: status, className: "status-muted" };

  return (
    <span className={`status-badge ${meta.className || "status-muted"}`}>
      {meta.label}
    </span>
  );
}

export default function Tickets() {
  const [tickets, setTickets] = useState([]);
  const [selected, setSelected] = useState(null);
  const [rejectNote, setRejectNote] = useState("");
  const [statusFilter, setStatusFilter] = useState("all");
  const [search, setSearch] = useState("");
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");
  const [verifyError, setVerifyError] = useState("");
  const [actionLoading, setActionLoading] = useState("");
  const [exporting, setExporting] = useState("");

  const fetchData = useCallback(async () => {
    setLoading(true);
    setError("");

    try {
      const res = await api.get("/api/web-admin/bookings");
      setTickets(Array.isArray(res.data?.data) ? res.data.data : []);
    } catch (err) {
      setError(getApiErrorMessage(err, "Gagal memuat data booking"));
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    fetchData();
  }, [fetchData]);

  const filteredTickets = useMemo(() => {
    const keyword = search.trim().toLowerCase();

    return tickets.filter((ticket) => {
      const matchesStatus =
        statusFilter === "all" || ticket.status === statusFilter;
      const haystack = [
        ticket.id,
        ticket.route_name,
        ticket.status,
        ticket.user_id,
      ]
        .filter(Boolean)
        .join(" ")
        .toLowerCase();

      return matchesStatus && (!keyword || haystack.includes(keyword));
    });
  }, [tickets, search, statusFilter]);

  const stats = useMemo(
    () =>
      statusOptions.reduce((acc, status) => {
        acc[status] =
          status === "all"
            ? tickets.length
            : tickets.filter((ticket) => ticket.status === status).length;
        return acc;
      }, {}),
    [tickets]
  );

  const closeModal = () => {
    setSelected(null);
    setRejectNote("");
    setVerifyError("");
    setActionLoading("");
  };

  const verify = async (action) => {
    if (!selected) return;
    if (action === "reject" && rejectNote.trim().length === 0) {
      setVerifyError("Catatan penolakan wajib diisi");
      return;
    }

    setVerifyError("");
    setActionLoading(action);
    try {
      await api.put(`/api/web-admin/verify-payment/${selected.id}`, {
        action,
        reject_note: rejectNote.trim(),
      });

      await fetchData();
      closeModal();
    } catch (err) {
      setVerifyError(getApiErrorMessage(err, "Gagal verifikasi pembayaran"));
    } finally {
      setActionLoading("");
    }
  };

  const downloadExport = async (type) => {
    setExporting(type);
    setError("");

    try {
      const res = await api.get(`/api/web-admin/export/${type}`, {
        responseType: "blob",
      });
      const extension = type === "csv" ? "csv" : "pdf";
      const blobUrl = URL.createObjectURL(res.data);
      const link = document.createElement("a");

      link.href = blobUrl;
      link.download = `gotrip-bookings.${extension}`;
      document.body.appendChild(link);
      link.click();
      link.remove();
      URL.revokeObjectURL(blobUrl);
    } catch (err) {
      setError(getApiErrorMessage(err, "Gagal mengunduh laporan"));
    } finally {
      setExporting("");
    }
  };

  const proofUrl = getProofImageUrl(selected?.proof_image);
  const canVerifyPayment = selected?.status === "waiting_verification";

  return (
    <AdminLayout
      title="Booking"
      subtitle="Kelola booking pendakian, bukti pembayaran, dan laporan."
      actions={
        <>
          <button
            className="btn btn-secondary"
            onClick={() => downloadExport("csv")}
            disabled={Boolean(exporting)}
          >
            {exporting === "csv" ? "Mengunduh..." : "Export CSV"}
          </button>
          <button
            className="btn btn-secondary"
            onClick={() => downloadExport("pdf")}
            disabled={Boolean(exporting)}
          >
            {exporting === "pdf" ? "Mengunduh..." : "Export PDF"}
          </button>
          <button className="btn" onClick={fetchData} disabled={loading}>
            Refresh
          </button>
        </>
      }
    >
      {error && (
        <div className="alert alert-danger">
          <span>{error}</span>
          <button className="btn btn-text" onClick={fetchData}>
            Coba lagi
          </button>
        </div>
      )}

      <div className="ticket-stats">
        {statusOptions.map((status) => (
          <button
            key={status}
            className={`filter-card ${statusFilter === status ? "active" : ""}`}
            onClick={() => setStatusFilter(status)}
          >
            <span>{statusMeta[status].label}</span>
            <strong>{stats[status] || 0}</strong>
          </button>
        ))}
      </div>

      <div className="toolbar">
        <input
          type="search"
          placeholder="Cari ID booking, jalur, atau status..."
          value={search}
          onChange={(e) => setSearch(e.target.value)}
        />
      </div>

      <div className="card table-card">
        {loading ? (
          <div className="empty-state">Memuat booking...</div>
        ) : filteredTickets.length === 0 ? (
          <div className="empty-state">Tidak ada booking</div>
        ) : (
          <div className="table-responsive">
            <table className="data-table">
              <thead>
                <tr>
                  <th>ID</th>
                  <th>Jalur</th>
                  <th>Tanggal</th>
                  <th>Orang</th>
                  <th>Ojek</th>
                  <th>Total</th>
                  <th>Status</th>
                  <th>Aksi</th>
                </tr>
              </thead>

              <tbody>
                {filteredTickets.map((ticket) => (
                  <tr key={ticket.id}>
                    <td className="mono truncate">{ticket.id}</td>
                    <td>
                      <strong>{ticket.route_name || "Unknown"}</strong>
                      <span className="table-subtext">
                        Booking {formatDate(ticket.booking_date)}
                      </span>
                    </td>
                    <td>{formatDate(ticket.hiking_date)}</td>
                    <td>{ticket.total_members || 0}</td>
                    <td>{ticket.include_ojek ? ticket.ojek_count || 1 : 0}</td>
                    <td>{formatRupiah(ticket.total_price)}</td>
                    <td>
                      <StatusBadge status={ticket.status} />
                    </td>
                    <td>
                      <button
                        className="btn btn-sm"
                        onClick={() => setSelected(ticket)}
                        disabled={!ticket.proof_image}
                      >
                        {ticket.status === "waiting_verification"
                          ? "Verifikasi"
                          : "Detail"}
                      </button>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </div>

      {selected && (
        <div className="modal-overlay" role="dialog" aria-modal="true">
          <div className="modal-box ticket-modal">
            <div className="modal-header">
              <div>
                <p className="eyebrow">Pembayaran</p>
                <h2>Verifikasi Booking</h2>
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
                <span>ID Booking</span>
                <strong className="mono">{selected.id}</strong>
              </div>
              <div>
                <span>Total</span>
                <strong>{formatRupiah(selected.total_price)}</strong>
              </div>
              <div>
                <span>Jalur</span>
                <strong>{selected.route_name || "Unknown"}</strong>
              </div>
              <div>
                <span>Status</span>
                <StatusBadge status={selected.status} />
              </div>
            </div>

            {proofUrl ? (
              <img
                className="proof-image"
                src={proofUrl}
                alt={`Bukti pembayaran booking ${selected.id}`}
              />
            ) : (
              <div className="empty-state compact">Bukti belum diunggah</div>
            )}

            {selected.reject_note && (
              <div className="alert alert-warning">
                Catatan sebelumnya: {selected.reject_note}
              </div>
            )}

            <label className="field-label" htmlFor="reject-note">
              Catatan penolakan
            </label>
            <textarea
              id="reject-note"
              className="reject-textarea"
              placeholder={
                canVerifyPayment
                  ? "Tulis alasan jika pembayaran ditolak"
                  : "Pembayaran sudah tidak menunggu verifikasi"
              }
              value={rejectNote}
              onChange={(e) => setRejectNote(e.target.value)}
              disabled={!canVerifyPayment}
            />

            {verifyError && (
              <div className="alert alert-danger compact">{verifyError}</div>
            )}

            <div className="modal-actions">
              {canVerifyPayment && (
                <>
                  <button
                    className="btn btn-success"
                    onClick={() => verify("accept")}
                    disabled={Boolean(actionLoading) || !proofUrl}
                  >
                    {actionLoading === "accept" ? "Memproses..." : "Terima"}
                  </button>
                  <button
                    className="btn btn-danger"
                    onClick={() => verify("reject")}
                    disabled={Boolean(actionLoading) || !proofUrl}
                  >
                    {actionLoading === "reject" ? "Memproses..." : "Tolak"}
                  </button>
                </>
              )}
              <button className="btn btn-secondary" onClick={closeModal}>
                Tutup
              </button>
            </div>
          </div>
        </div>
      )}
    </AdminLayout>
  );
}
