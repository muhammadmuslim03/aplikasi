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
import { useCallback, useEffect, useMemo, useState } from "react";
import AdminLayout from "../components/AdminLayout";
import api, { getApiErrorMessage } from "../api/api";

const defaultSummary = {
  total_revenue: 0,
  total_tickets: 0,
  total_hikers: 0,
  total_pending: 0,
  total_users: 0,
  total_active_hikers: 0,
  total_finished_hikers: 0,
};

const hikingStatusMeta = {
  paid: { label: "Siap check-in", className: "status-success" },
  checked_in: { label: "Sedang mendaki", className: "status-info" },
  checked_out: { label: "Selesai", className: "status-muted" },
};

const hikingStatusOrder = {
  checked_in: 0,
  paid: 1,
  checked_out: 2,
};

const code128Patterns = [
  "212222", "222122", "222221", "121223", "121322", "131222", "122213",
  "122312", "132212", "221213", "221312", "231212", "112232", "122132",
  "122231", "113222", "123122", "123221", "223211", "221132", "221231",
  "213212", "223112", "312131", "311222", "321122", "321221", "312212",
  "322112", "322211", "212123", "212321", "232121", "111323", "131123",
  "131321", "112313", "132113", "132311", "211313", "231113", "231311",
  "112133", "112331", "132131", "113123", "113321", "133121", "313121",
  "211331", "231131", "213113", "213311", "213131", "311123", "311321",
  "331121", "312113", "312311", "332111", "314111", "221411", "431111",
  "111224", "111422", "121124", "121421", "141122", "141221", "112214",
  "112412", "122114", "122411", "142112", "142211", "241211", "221114",
  "413111", "241112", "134111", "111242", "121142", "121241", "114212",
  "124112", "124211", "411212", "421112", "421211", "212141", "214121",
  "412121", "111143", "111341", "131141", "114113", "114311", "411113",
  "411311", "113141", "114131", "311141", "411131", "211412", "211214",
  "211232", "2331112",
];

const formatRupiah = (num) =>
  new Intl.NumberFormat("id-ID", {
    style: "currency",
    currency: "IDR",
    minimumFractionDigits: 0,
  }).format(num || 0);

const formatNumber = (num) =>
  new Intl.NumberFormat("id-ID").format(Number(num) || 0);

const formatMonth = (value) => {
  if (!value) return "-";

  const [year, month] = String(value).split("-");
  const date = new Date(Number(year), Number(month) - 1, 1);

  if (Number.isNaN(date.getTime())) return value;

  return new Intl.DateTimeFormat("id-ID", {
    month: "short",
    year: "2-digit",
  }).format(date);
};

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

const getDateTime = (dateString) => {
  const date = new Date(dateString);

  return Number.isNaN(date.getTime()) ? 0 : date.getTime();
};

const encodeCode128B = (value) => {
  const text = String(value || "");
  const codes = [104];

  for (const char of text) {
    const code = char.charCodeAt(0) - 32;
    if (code < 0 || code > 94) return [];
    codes.push(code);
  }

  const checksum =
    codes.reduce((total, code, index) => {
      if (index === 0) return total + code;
      return total + code * index;
    }, 0) % 103;

  return [...codes, checksum, 106];
};

const getBarcodeBars = (value) => {
  const codes = encodeCode128B(value);
  let x = 0;

  return codes.flatMap((code) => {
    const pattern = code128Patterns[code] || "";

    return pattern.split("").flatMap((width, index) => {
      const numericWidth = Number(width);
      const bar = {
        x,
        width: numericWidth,
        isBar: index % 2 === 0,
      };

      x += numericWidth;
      return bar.isBar ? [bar] : [];
    });
  });
};

const getBarcodeWidth = (value) =>
  encodeCode128B(value).reduce((total, code) => {
    const pattern = code128Patterns[code] || "";

    return (
      total +
      pattern
        .split("")
        .reduce((patternTotal, width) => patternTotal + Number(width), 0)
    );
  }, 0);

const normalizeChart = (items = []) =>
  items.map((item) => ({
    ...item,
    label: formatMonth(item.bulan),
    total: Number(item.total) || 0,
  }));

function StatCard({ label, value, tone, helper }) {
  return (
    <div className={`stat-card ${tone ? `stat-card-${tone}` : ""}`}>
      <span>{label}</span>
      <strong>{value}</strong>
      {helper && <small>{helper}</small>}
    </div>
  );
}

function ChartCard({ title, empty, children }) {
  return (
    <div className="card chart-card">
      <div className="card-heading">
        <h2>{title}</h2>
      </div>

      {empty ? (
        <div className="empty-state compact">Belum ada data</div>
      ) : (
        <div className="chart-wrap">{children}</div>
      )}
    </div>
  );
}

function HikingStatusBadge({ status }) {
  const meta = hikingStatusMeta[status] || {
    label: status || "-",
    className: "status-muted",
  };

  return (
    <span className={`status-badge ${meta.className}`}>{meta.label}</span>
  );
}

function Code128Barcode({ value }) {
  const bars = useMemo(() => getBarcodeBars(value), [value]);
  const width = Math.max(getBarcodeWidth(value), 1);

  return (
    <svg
      className="barcode-svg"
      viewBox={`0 0 ${width} 64`}
      role="img"
      aria-label={`Barcode ${value}`}
      preserveAspectRatio="none"
    >
      <rect width={width} height="64" fill="#ffffff" />
      {bars.map((bar, index) => (
        <rect
          key={`${bar.x}-${index}`}
          x={bar.x}
          y="0"
          width={bar.width}
          height="64"
          fill="#111827"
        />
      ))}
    </svg>
  );
}

function BarcodeCard({ title, code, helper }) {
  return (
    <div className="barcode-card">
      <div className="barcode-card-heading">
        <h3>{title}</h3>
        <span>{helper}</span>
      </div>
      <Code128Barcode value={code} />
      <strong className="barcode-code">{code}</strong>
    </div>
  );
}

export default function Dashboard() {
  const [summary, setSummary] = useState(defaultSummary);
  const [chart, setChart] = useState({ pendapatan: [], pendaki: [] });
  const [bookings, setBookings] = useState([]);
  const [barcodes, setBarcodes] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");

  const fetchData = useCallback(async () => {
    setLoading(true);
    setError("");

    try {
      const [summaryRes, pendapatanRes, pendakiRes, bookingsRes, barcodesRes] =
        await Promise.all([
          api.get("/api/web-admin/dashboard"),
          api.get("/api/web-admin/chart/pendapatan"),
          api.get("/api/web-admin/chart/pendaki"),
          api.get("/api/web-admin/bookings"),
          api.get("/api/web-admin/barcodes"),
        ]);

      setSummary({ ...defaultSummary, ...summaryRes.data });
      setChart({
        pendapatan: normalizeChart(pendapatanRes.data?.data || []),
        pendaki: normalizeChart(pendakiRes.data?.data || []),
      });
      setBookings(
        Array.isArray(bookingsRes.data?.data) ? bookingsRes.data.data : []
      );
      setBarcodes(barcodesRes.data?.data || null);
    } catch (err) {
      setError(getApiErrorMessage(err, "Gagal memuat dashboard"));
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    fetchData();
  }, [fetchData]);

  const statCards = useMemo(
    () => [
      {
        label: "Pendapatan",
        value: formatRupiah(summary.total_revenue),
        tone: "revenue",
        helper: "Booking terbayar",
      },
      {
        label: "Booking",
        value: formatNumber(summary.total_bookings ?? summary.total_tickets),
        helper: "Total pemesanan",
      },
      {
        label: "Pendaki",
        value: formatNumber(summary.total_hikers),
        tone: "hikers",
        helper: `${formatNumber(summary.total_users)} akun`,
      },
      {
        label: "Di Gunung",
        value: formatNumber(summary.total_active_hikers),
        tone: "active",
        helper: "Sudah check-in",
      },
      {
        label: "Check-out",
        value: formatNumber(summary.total_finished_hikers),
        tone: "finished",
        helper: "Pendaki selesai",
      },
      {
        label: "Menunggu",
        value: formatNumber(summary.total_pending),
        tone: "pending",
        helper: "Belum dibayar",
      },
    ],
    [summary]
  );

  const hikingTickets = useMemo(
    () =>
      bookings
        .filter((booking) => Boolean(hikingStatusMeta[booking.status]))
        .sort((a, b) => {
          const statusDiff =
            hikingStatusOrder[a.status] - hikingStatusOrder[b.status];

          if (statusDiff !== 0) return statusDiff;

          return getDateTime(a.hiking_date) - getDateTime(b.hiking_date);
        }),
    [bookings]
  );

  return (
    <AdminLayout
      title="Dashboard"
      subtitle="Ringkasan booking, pembayaran, dan status pendakian."
      actions={
        <button className="btn btn-secondary" onClick={fetchData}>
          Refresh
        </button>
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

      <div className="summary-grid">
        {statCards.map((item) => (
          <StatCard key={item.label} {...item} />
        ))}
      </div>

      <div className="barcode-grid">
        <BarcodeCard
          title={barcodes?.check_in?.label || "Barcode Check-in"}
          code={barcodes?.check_in?.code || "GOTRIP_CHECK_IN"}
          helper="Scan saat pendaki masuk"
        />
        <BarcodeCard
          title={barcodes?.check_out?.label || "Barcode Check-out"}
          code={barcodes?.check_out?.code || "GOTRIP_CHECK_OUT"}
          helper="Scan saat pendaki keluar"
        />
      </div>

      {loading ? (
        <div className="grid-2">
          <div className="card skeleton-card" />
          <div className="card skeleton-card" />
        </div>
      ) : (
        <div className="grid-2">
          <ChartCard
            title="Pendapatan Bulanan"
            empty={chart.pendapatan.length === 0}
          >
            <ResponsiveContainer width="100%" height="100%">
              <AreaChart data={chart.pendapatan}>
                <CartesianGrid strokeDasharray="3 3" stroke="#dde7e3" />
                <XAxis dataKey="label" tickLine={false} axisLine={false} />
                <YAxis
                  tickLine={false}
                  axisLine={false}
                  tickFormatter={(value) => `${Number(value) / 1000}k`}
                />
                <Tooltip
                  formatter={(value) => formatRupiah(value)}
                  labelFormatter={(label) => `Bulan ${label}`}
                />
                <Area
                  type="monotone"
                  dataKey="total"
                  stroke="#1d6f5a"
                  fill="#cde8df"
                  strokeWidth={3}
                />
              </AreaChart>
            </ResponsiveContainer>
          </ChartCard>

          <ChartCard title="Akun Pendaki" empty={chart.pendaki.length === 0}>
            <ResponsiveContainer width="100%" height="100%">
              <LineChart data={chart.pendaki}>
                <CartesianGrid strokeDasharray="3 3" stroke="#dde7e3" />
                <XAxis dataKey="label" tickLine={false} axisLine={false} />
                <YAxis tickLine={false} axisLine={false} />
                <Tooltip labelFormatter={(label) => `Bulan ${label}`} />
                <Line
                  type="monotone"
                  dataKey="total"
                  stroke="#2c6f9f"
                  strokeWidth={3}
                  dot={{ r: 4 }}
                  activeDot={{ r: 6 }}
                />
              </LineChart>
            </ResponsiveContainer>
          </ChartCard>
        </div>
      )}

      <div className="card table-card hiking-card">
        <div className="table-card-header">
          <div>
            <h2>Check-in / Check-out Pendakian</h2>
            <p>
              Pantau booking terbayar, pendaki yang sudah scan masuk, dan yang
              selesai scan keluar.
            </p>
          </div>
          <span className="table-count">
            {formatNumber(hikingTickets.length)}
          </span>
        </div>

        {loading ? (
          <div className="empty-state">Memuat data pendakian...</div>
        ) : hikingTickets.length === 0 ? (
          <div className="empty-state">Belum ada booking siap check-in</div>
        ) : (
          <div className="table-responsive">
            <table className="data-table hiking-table">
              <thead>
                <tr>
                  <th>ID</th>
                  <th>Pendaki</th>
                  <th>Jalur</th>
                  <th>Jadwal</th>
                  <th>Orang</th>
                  <th>Status</th>
                  <th>Waktu</th>
                </tr>
              </thead>

              <tbody>
                {hikingTickets.map((ticket) => {
                  const userName =
                    ticket.user?.name || `User #${ticket.user_id}`;

                  return (
                    <tr key={ticket.id}>
                      <td className="mono truncate">{ticket.id}</td>
                      <td>
                        <strong>{userName}</strong>
                        {ticket.user?.phone && (
                          <span className="table-subtext">
                            {ticket.user.phone}
                          </span>
                        )}
                      </td>
                      <td>{ticket.route_name || "Unknown"}</td>
                      <td>{formatDate(ticket.hiking_date)}</td>
                      <td>{formatNumber(ticket.total_members)}</td>
                      <td>
                        <HikingStatusBadge status={ticket.status} />
                      </td>
                      <td>
                        <span className="time-stack">
                          <span>
                            In: {formatDateTime(ticket.checked_in_at)}
                          </span>
                          <span>
                            Out: {formatDateTime(ticket.checked_out_at)}
                          </span>
                        </span>
                      </td>
                    </tr>
                  );
                })}
              </tbody>
            </table>
          </div>
        )}
      </div>
    </AdminLayout>
  );
}
