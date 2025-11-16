// TEMPORARY AUTH MIDDLEWARE FOR LOCAL DEMO
// In a real app, this would verify Firebase ID tokens.

export const verifyIdToken = async (req, res, next) => {
  // Normally you'd read the Authorization header and verify with Firebase Admin.
  // For demo purposes, just attach a fake user.
  req.user = {
    uid: "demo-user",
    email: "demo@example.com",
    role: "admin",
  };
  next();
};

export const requireAuth = (req, res, next) => {
  // Normally: if (!req.user) return res.status(401)...
  next();
};

export const requireAdmin = (req, res, next) => {
  // Normally: check req.user.role === 'admin'
  next();
};
