import Navbar from "./Navbar";
import Sidebar from "./Sidebar";

export default function AdminLayout({ title, subtitle, actions, children }) {
  return (
    <div className="app-layout">
      <Sidebar />
      <main className="main">
        <Navbar />

        <section className="content">
          <div className="page-header">
            <div>
              <p className="eyebrow">GOTRIP Admin</p>
              <h1>{title}</h1>
              {subtitle && <p className="page-subtitle">{subtitle}</p>}
            </div>

            {actions && <div className="page-actions">{actions}</div>}
          </div>

          {children}
        </section>
      </main>
    </div>
  );
}
