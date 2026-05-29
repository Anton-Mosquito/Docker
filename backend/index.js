const express = require("express");
const app = express();

app.use(express.json());
app.use((req, res, next) => {
  // CORS для React
  res.header("Access-Control-Allow-Origin", "*");
  next();
});

app.get("/api/items", (req, res) => {
  res.json([
    { id: 1, name: "Item from Docker!" },
    { id: 2, name: "Served via compose" },
  ]);
});

app.listen(5000, () => console.log("API on :5000"));
