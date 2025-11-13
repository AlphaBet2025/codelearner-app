import admin from "../services/firebaseAdmin.js";

export async function verifyIdToken(req, res, next) {
  try {
    const auth = req.headers.authorization || "";
    const token = auth.startsWith("Bearer ") ? auth.slice(7) : null;
    if (!token) return res.status(401).json({ error: "Missing token" });

    const decoded = await admin.auth().verifyIdToken(token, true);
    req.user = {
      uid: decoded.uid,
      email: decoded.email || null,
      isAdmin: decoded.admin === true
    };
    next();
  } catch {
    res.status(401).json({ error: "Invalid token" });
  }
}

export function requireAuth(req, res, next) {
  if (!req.user?.uid) return res.status(401).json({ error: "Unauthorized" });
  next();
}

export function requireAdmin(req, res, next) {
  if (!req.user?.isAdmin) return res.status(403).json({ error: "Admin only" });
  next();
}
