// TEMPORARY STUB FOR DEMO
// This avoids needing real Firebase credentials.

const admin = {
  auth() {
    return {
      // Pretend to verify token and always return a fake user
      verifyIdToken: async (token) => {
        return {
          uid: "demo-user",
          email: "demo@example.com",
          role: "admin",
        };
      },
    };
  },
};

export default admin;
