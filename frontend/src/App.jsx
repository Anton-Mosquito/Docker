import { useEffect, useState } from "react";

const API_BASE = import.meta.env.VITE_API_URL ?? "http://backend:5000";

export default function App() {
  const [items, setItems] = useState([]);
  useEffect(() => {
    fetch(`${API_BASE}/api/items`)
      .then((r) => r.json())
      .then(setItems)
      .catch(() => setItems([]));
  }, []);

  return (
    <div style={{ fontFamily: "sans-serif", padding: 16 }}>
      <h1>Vite env: VITE_API_URL</h1>
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

// WATCH_POLL_TEST_1779956930

// WATCH_POLL_TEST_1779956930

// WATCH_POLL_SIMPLE_1779957125

// WATCH_POLL_SIMPLE_1779957125
