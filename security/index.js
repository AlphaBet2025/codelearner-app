import "dotenv/config";
import express from "express";
import helmet from "helmet";
import cors from "cors";
import rateLimit from "express-rate-limit";
import { z } from "zod";
import { pool } from "./security/services/db.js";
import admin from "./security/services/firebaseAdmin.js";
import { verifyIdToken, requireAuth, requireAdmin } from "./security/middleware/auth.js";

const app = express();
app.use(express.json({ limit: "1mb" }));
app.use(helmet());
app.use(cors({ origin: process.env.CORS_ORIGIN || "*", credentials: true }));

const limiter = rateLimit({
  windowMs: 60 * 1000,
  limit: 60
});
app.use(limiter);

async function upsertUser({ uid, email, displayName }) {
  const [rows] = await pool.query(
    "SELECT id, role FROM users WHERE firebase_uid = ?",
    [uid]
  );
  if (rows.length > 0) {
    await pool.query(
      "UPDATE users SET email = ?, display_name = ?, last_login_at = NOW() WHERE firebase_uid = ?",
      [email || "", displayName || null, uid]
    );
    return { exists: true, role: rows[0].role };
  }
  await pool.query(
    "INSERT INTO users (firebase_uid, email, display_name, role, created_at, updated_at, last_login_at) VALUES (?, ?, ?, 'user', NOW(), NOW(), NOW())",
    [uid, email || "", displayName || null]
  );
  return { exists: false, role: "user" };
}

app.get("/healthz", (_, res) => res.json({ ok: true }));

// Simple homepage to avoid the default Express "Cannot GET /" message
app.get("/", (req, res) => {
  res.send(`
    <!doctype html>
    <html>
      <head><meta charset="utf-8"><title>Codecoach Backend</title></head>
      <body style="font-family:system-ui,Segoe UI,Helvetica,Arial;line-height:1.4;margin:2rem">
        <h1>Codecoach Backend</h1>
        <p>Server is running. Try these endpoints:</p>
        <ul>
          <li><a href="/healthz">/healthz</a> — health check</li>
          <li><a href="/api/me">/api/me</a> — protected user info (requires auth)</li>
        </ul>
        <p>Note: some API routes require Firebase and DB env vars to be set.</p>
      </body>
    </html>
  `);
});

app.post("/api/auth/first-login", verifyIdToken, requireAuth, async (req, res) => {
  try {
    const userRecord = await admin.auth().getUser(req.user.uid);
    const email = userRecord.email || null;
    const displayName = userRecord.displayName || null;
    const info = await upsertUser({ uid: req.user.uid, email, displayName });
    res.json({ ok: true, newUser: !info.exists, role: info.role });
  } catch (e) {
    res.status(500).json({ error: "Failed to upsert user" });
  }
});

app.get("/api/me", verifyIdToken, requireAuth, async (req, res) => {
  const [rows] = await pool.query(
    "SELECT email, display_name, role, created_at, last_login_at FROM users WHERE firebase_uid = ?",
    [req.user.uid]
  );
  if (!rows.length) return res.status(404).json({ error: "Not found" });
  res.json({ ...rows[0], uid: req.user.uid });
});

app.get("/api/admin/users", verifyIdToken, requireAuth, requireAdmin, async (req, res) => {
  const [rows] = await pool.query("SELECT * FROM users LIMIT 200");
  res.json({ users: rows });
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log("Running on " + PORT));
