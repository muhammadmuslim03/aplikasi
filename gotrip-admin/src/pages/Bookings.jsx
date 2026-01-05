import React, { useEffect, useState } from "react";
import axios from "axios";
import Navbar from "../components/Navbar";
import Sidebar from "../components/Sidebar";

const formatDate = (dateString) => {
  if (!dateString) return "-";
  try {
    const dateOnly = dateString.slice(0, 10); 
    return new Date(dateOnly).toLocaleDateString("id-ID", {
      year: 'numeric',
      month: '2-digit',
      day: '2-digit'
    });
  } catch (e) {
    return dateString;
  }
};

const getAuthToken = () => {
    return localStorage.getItem("authToken") || localStorage.getItem("token_admin"); 
};

const getProofImageUrl = (proofImagePath) => {
    if (!proofImagePath) return null;
    const cleanedPath = proofImagePath.replace(/^uploads\//, ''); 
    return `http://localhost:8080/uploads/${cleanedPath}`;
};


export default function Bookings() {
  const [bookings, setBookings] = useState([]);
  const [selectedBooking, setSelectedBooking] = useState(null);
  const [rejectNote, setRejectNote] = useState("");
  const [loading, setLoading] = useState(true); 
  const [error, setError] = useState(null); 

  const fetchBookings = async () => {
    setLoading(true);
    setError(null);
    const token = getAuthToken();

    if (!token) {
      setError("Token admin tidak ditemukan. Harap login terlebih dahulu.");
      setLoading(false);
      return; 
    }

    try {
      const res = await axios.get("http://localhost:8080/api/web-admin/bookings", {
        headers: {
          Authorization: `Bearer ${token}`,
        },
      });

      const cleanedData = (res.data.data || []).map((b) => ({
        id: b.id,
        nama: b.nama,
        email: b.email,
        tanggal: b.tanggal,
        orang: b.jumlah_orang,     
        ojek: b.jumlah_ojek,       
        total_harga: b.total_harga,
        status: b.status,
        proof_image: b.proof_image ? b.proof_image : null,
      }));

      setBookings(cleanedData);
    } catch (err) {
      console.error("Gagal mengambil booking:", err);
      if (err.response && err.response.status === 401) {
        setError("Otentikasi Gagal (401). Token tidak valid atau kedaluwarsa. Harap login ulang.");
      } else {
        setError(err.response?.data?.message || "Gagal terhubung ke server atau terjadi error.");
      }
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchBookings();
  }, []);

  const openModal = (b) => {
    setSelectedBooking(b);
    setRejectNote("");
  };

  const closeModal = () => setSelectedBooking(null);

  const handleVerify = async (action) => {
    if (!selectedBooking) return;

    setLoading(true);
    try {
      const token = getAuthToken();
      
      if (!token) {
        alert("Token hilang. Harap login kembali.");
        setLoading(false);
        return;
      }

      await axios.put(
        `http://localhost:8080/api/web-admin/verify-payment/${selectedBooking.id}`,
        {
          action,
          reject_note: action === "reject" ? rejectNote : "",
        },
        {
          headers: {
            Authorization: `Bearer ${token}`,
          },
        }
      );

      await fetchBookings(); 
      closeModal();
    } catch (err) {
      alert("Gagal memverifikasi: " + err.response?.data?.message);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="app-layout">
      <Sidebar />

      <div className="main">
        <Navbar />

        <div className="content">
          <div className="section-title">Daftar Booking Pendaki</div>
          
          {loading && (
            <div style={{ textAlign: "center", padding: "40px", fontSize: "1.1em" }}>
              ⏳ Memuat data booking...
            </div>
          )}
          
          {error && !loading && (
            <div style={{ color: '#dc3545', backgroundColor: '#f8d7da', border: '1px solid #f5c6cb', padding: '15px', margin: '20px auto', borderRadius: '5px', textAlign: 'center' }}>
              ⚠️ **Gagal mengambil data:** {error}
              <p style={{ marginTop: '10px', fontSize: '0.9em' }}>Harap pastikan Anda sudah login sebagai Admin.</p>
            </div>
          )}
          
          {!loading && !error && (
            <table className="booking-table">
              <thead>
                <tr>
                  <th>ID</th>
                  <th>Nama</th>
                  <th>Email</th>
                  <th>Tanggal</th>
                  <th>Orang</th>
                  <th>Ojek</th>
                  <th>Total Harga</th>
                  <th>Status</th>
                  <th>Bukti</th>
                </tr>
              </thead>

              <tbody>
                {bookings.length === 0 ? (
                  <tr>
                    <td colSpan="9" style={{ textAlign: "center", padding: 20 }}>
                      Tidak ada data booking.
                    </td>
                  </tr>
                ) : (
                  bookings.map((b) => (
                    <tr key={b.id}>
                      <td>{b.id}</td>
                      <td>{b.nama}</td>
                      <td>{b.email}</td>
                      <td>{formatDate(b.tanggal)}</td> 
                      <td>{b.orang}</td> 
                      <td>{b.ojek}</td>  
                      <td>Rp {b.total_harga.toLocaleString()}</td>
                      <td className={`status-label status-${b.status}`}>
                        {b.status}
                      </td>
                      <td>
                        {b.proof_image ? (
                          <button className="btn-view" onClick={() => openModal(b)}>
                            Lihat/Aksi
                          </button>
                        ) : (
                          "-"
                        )}
                      </td>
                    </tr>
                  ))
                )}
              </tbody>
            </table>
          )}

          {selectedBooking && (
            <div className="modal-overlay">
              <div className="modal-box" style={{ maxHeight: '90vh', overflowY: 'auto' }}> 
                <h3>Verifikasi Pembayaran</h3>

                <p><strong>Nama:</strong> {selectedBooking.nama}</p>
                <p><strong>Email:</strong> {selectedBooking.email}</p>
                <p>
                  <strong>Total Harga:</strong> Rp{" "}
                  {selectedBooking.total_harga.toLocaleString()}
                </p>

                {selectedBooking.proof_image && (
                  <img
                    src={getProofImageUrl(selectedBooking.proof_image)}
                    alt="Bukti Pembayaran"
                    className="proof-image"
                    onError={(e) => {
                        e.target.onerror = null;
                        e.target.src = "https://placehold.co/400x200/cccccc/333333?text=Gambar+Hilang";
                    }}
                  />
                )}

                <textarea
                  className="reject-textarea"
                  placeholder="Catatan penolakan (opsional)"
                  value={rejectNote}
                  onChange={(e) => setRejectNote(e.target.value)}
                />

                <div className="modal-actions">
                  <button className="btn-accept" disabled={loading} onClick={() => handleVerify("accept")}>
                    Terima
                  </button>
                  <button className="btn-reject" disabled={loading} onClick={() => handleVerify("reject")}>
                    Tolak
                  </button>
                  <button className="btn-cancel" onClick={closeModal}>
                    Tutup
                  </button>
                </div>
              </div>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}