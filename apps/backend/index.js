const express = require("express");
const app = express();
const db = require("./db");

const startTime = Date.now();

app.use(express.json());
app.use((req, res, next) => {
  res.header("Access-Control-Allow-Origin", "*");
  next();
});

app.get("/api/items", (req, res) => {
  res.json([
    { id: 1, name: "Item from Docker!" },
    { id: 2, name: "Served via compose" },
  ]);
});

app.get("/health", (req, res) => {
  const uptime = Math.floor((Date.now() - startTime) / 1000);
  res.json({ status: "ok", uptime });
});

app.get("/api/db-test", async (req, res) => {
  try {
    const result = await db.query("SELECT NOW() as now");
    res.json({ status: "ok", time: result.rows[0].now });
  } catch (err) {
    console.error(err);
    res.status(500).json({ status: "error", error: err.message });
  }
});

const port = parseInt(process.env.PORT, 10) || 5000;
app.listen(port, () => console.log(`API on :${port}`));


