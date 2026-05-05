import { NavLink } from "react-router-dom";

const menuItems = [
  { to: "/", label: "Dashboard", end: true, code: "DB" },
  { to: "/tickets", label: "Booking", code: "BK" },
  { to: "/users", label: "Pendaki", code: "PD" },
];

export default function Sidebar() {
  return (
    <aside className="sidebar">
      <div className="sidebar-brand">
        <div className="brand-mark">GT</div>
        <div>
          <h2>GOTRIP</h2>
          <span>Admin Panel</span>
        </div>
      </div>

      <nav className="sidebar-nav">
        {menuItems.map((item) => (
          <NavLink
            key={item.to}
            to={item.to}
            end={item.end}
            className={({ isActive }) =>
              isActive ? "sidebar-link active" : "sidebar-link"
            }
          >
            <span className="sidebar-link-code">{item.code}</span>
            <span>{item.label}</span>
          </NavLink>
        ))}
      </nav>
    </aside>
  );
}
