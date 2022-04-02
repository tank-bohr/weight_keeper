CREATE TABLE IF NOT EXISTS weights (
  id serial PRIMARY KEY,
  user_id INT NOT NULL,
  value DECIMAL NOT NULL,
  inserted_at TIMESTAMP
);
