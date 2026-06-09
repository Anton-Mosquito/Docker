import { useEffect, useState } from "react";

const API_BASE = import.meta.env.VITE_API_URL || "/api";

export default function App() {
  const [items, setItems] = useState([]);
  useEffect(() => {
    fetch(`${API_BASE}/items`)
      .then((r) => r.json())
      .then(setItems)
      .catch(() => setItems([]));
  }, []);

  return (
    <div style={{ fontFamily: "sans-serif", padding: 16 }}>
      <h1>Vite env: API_BASE</h1>
      <p>{API_BASE}</p>
      <h2>Items from API</h2>
      <ul>
        {items.map((it) => (
          <li key={it.id}>{it.name}</li>
        ))}
      </ul>
      <h5>Vite env: VITE_API_URL</h5>
    </div>
  );
}
