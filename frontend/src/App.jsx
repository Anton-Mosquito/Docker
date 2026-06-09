import { useEffect, useState } from "react";
import { Link, Navigate, Route, Routes } from "react-router-dom";

const API_BASE = import.meta.env.VITE_API_URL || "/api";

function Home() {
  const [items, setItems] = useState([]);

  useEffect(() => {
    fetch(`${API_BASE}/items`)
      .then((r) => r.json())
      .then(setItems)
      .catch(() => setItems([]));
  }, []);

  return (
    <div style={{ fontFamily: "sans-serif", padding: 16 }}>
      <h1>Головна сторінка</h1>
      <p>API path: {API_BASE}</p>
      <h2>Items from API</h2>
      <ul>
        {items.map((it) => (
          <li key={it.id}>{it.name}</li>
        ))}
      </ul>
    </div>
  );
}

function About() {
  return (
    <div style={{ fontFamily: "sans-serif", padding: 16 }}>
      <h1>About</h1>
      <p>Це SPA-маршрут /about у React Router.</p>
    </div>
  );
}

function NotFound() {
  return (
    <div style={{ fontFamily: "sans-serif", padding: 16 }}>
      <h1>Сторінку не знайдено</h1>
      <p>
        <Link to="/">Повернутися на головну</Link>
      </p>
    </div>
  );
}

export default function App() {
  return (
    <div style={{ fontFamily: "sans-serif", padding: 16 }}>
      <nav style={{ marginBottom: 16 }}>
        <Link to="/" style={{ marginRight: 16 }}>
          Home
        </Link>
        <Link to="/about">About</Link>
      </nav>
      <Routes>
        <Route path="/" element={<Home />} />
        <Route path="/about" element={<About />} />
        <Route path="*" element={<NotFound />} />
      </Routes>
    </div>
  );
}
