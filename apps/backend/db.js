const { Pool } = require("pg");

const pool = new Pool({
  host: process.env.DB_HOST || "db",
  port: parseInt(process.env.DB_PORT, 10) || 5432,
  user: process.env.POSTGRES_USER,
  password: process.env.POSTGRES_PASSWORD,
  database: process.env.POSTGRES_DB,
});

pool.on("error", (err) => {
  console.error("Unexpected error on idle client", err);
  process.exit(-1);
});

module.exports = {
  query: (text, params) => pool.query(text, params),
};
