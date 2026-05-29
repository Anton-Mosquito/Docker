-- init.sql — executed by Postgres on first container initialization
-- Creates an `items` table and inserts a sample row

CREATE TABLE IF NOT EXISTS items (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT now()
);

INSERT INTO items (name) VALUES ('Initialized item');
