import "dotenv/config";
import express from "express";
import helmet from "helmet";
import cors from "cors";
import rateLimit from "express-rate-limit";
import { z } from "zod";
import { pool } from "./services/db.js";
import admin from "./services/firebaseAdmin.js";
import { verifyIdToken, requireAuth, requireAdmin } from "./middleware/auth.js";
import OpenAI from "openai";

const app = express();
const openai = new OpenAI({ apiKey: process.env.OPENAI_API_KEY });
app.use(express.json({ limit: "1mb" }));
app.use(helmet());
app.use(cors({ origin: process.env.CORS_ORIGIN || "*", credentials: true }));

function limitWords(text, maxWords) {
  const words = text.split(/\s+/);
  if (words.length <= maxWords) return text;
  return words.slice(0, maxWords).join(" ") + "...";
}

const limiter = rateLimit({
  windowMs: 60 * 1000,
  limit: 60
});
app.use(limiter);

app.use((req, res, next) => {
  console.log(req.method, req.url);
  next();
});


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


app.post("/api/ai/feedback", verifyIdToken, requireAuth, async (req, res) => {
  console.log("➡️  /api/ai/feedback hit", new Date().toISOString());

  try {
    const { codeSnippet, language } = req.body;
    


    if (!codeSnippet || typeof codeSnippet !== "string") {
      return res.status(400).json({ error: "codeSnippet is required" });
    }

    const response = await openai.responses.create({
      model: "gpt-4.1-mini",
      input: [
        {
          role: "system",
          content:
            "You are a helpful coding tutor. Explain what is wrong with the student code, how to improve it, and show a better version.",
        },
        {
          role: "user",
          content: `Language: ${language || "unknown"}\n\nCode:\n${codeSnippet}`,
        },
      ],
    });

    let text =
  response.output?.[0]?.content?.[0]?.text ||
  "No feedback generated.";

text = limitWords(text, 200);  // 🔥 LIMIT RESPONSE TO 200 WORDS

res.json({ feedback: text });

  } catch (err) {
    console.error("AI error:", err);
    res.status(500).json({ error: "AI service failed" });
  }
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log("Running on " + PORT));