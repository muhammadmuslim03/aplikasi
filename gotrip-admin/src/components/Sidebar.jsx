import { NavLink } from "react-router-dom";

export default function Sidebar() {
  return (
    <aside className="sidebar">
      <h2>GOTRIP</h2>
      <nav className="sidebar-nav">

        <NavLink
          to="/"
          end
          className={({ isActive }) => (isActive ? "sidebar-link active" : "sidebar-link")}
        >
          Dashboard
        </NavLink>

        <NavLink
          to="/bookings"
          className={({ isActive }) => (isActive ? "sidebar-link active" : "sidebar-link")}
        >
          Booking
        </NavLink>

        <NavLink
          to="/users"
          className={({ isActive }) => (isActive ? "sidebar-link active" : "sidebar-link")}
        >
          Pendaki
        </NavLink>

      </nav>
    </aside>
  );
}
