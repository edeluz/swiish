CREATE TABLE IF NOT EXISTS user_recovery_answers (
  user_id TEXT PRIMARY KEY,
  dni_hash TEXT NOT NULL,
  birth_city_hash TEXT NOT NULL,
  mother_birth_year_hash TEXT NOT NULL,
  primary_school_hash TEXT NOT NULL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);
