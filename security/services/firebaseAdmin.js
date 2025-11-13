import admin from "firebase-admin";

const hasFbCreds = process.env.FB_PROJECT_ID && process.env.FB_PRIVATE_KEY && process.env.FB_CLIENT_EMAIL;

let exportedAdmin;

if (hasFbCreds) {
  const serviceAccount = {
    type: process.env.FB_TYPE,
    project_id: process.env.FB_PROJECT_ID,
    private_key_id: process.env.FB_PRIVATE_KEY_ID,
    private_key: (process.env.FB_PRIVATE_KEY || "").replace(/\\n/g, "\n"),
    client_email: process.env.FB_CLIENT_EMAIL,
    client_id: process.env.FB_CLIENT_ID,
    auth_uri: process.env.FB_AUTH_URI,
    token_uri: process.env.FB_TOKEN_URI,
    auth_provider_x509_cert_url: process.env.FB_AUTH_PROVIDER_X509_CERT_URL,
    client_x509_cert_url: process.env.FB_CLIENT_X509_CERT_URL
  };

  if (!admin.apps.length) {
    admin.initializeApp({
      credential: admin.credential.cert(serviceAccount)
    });
  }

  exportedAdmin = admin;
} else {
  console.warn("Firebase admin not initialized: missing FB_* environment variables. Running in limited mode.");
  const dummyAdmin = {
    apps: [],
    credential: { cert: () => null },
    initializeApp: () => {},
    auth: () => ({
      getUser: async () => { throw new Error('Firebase admin disabled (missing env vars)'); },
      verifyIdToken: async () => { throw new Error('Firebase admin disabled (missing env vars)'); }
    })
  };

  exportedAdmin = dummyAdmin;
}

export default exportedAdmin;
