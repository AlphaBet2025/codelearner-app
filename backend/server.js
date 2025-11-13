import express from "express";
import bodyParser from "body-parser";
import OpenAI from "openai";
import dotenv from "dotenv";
import cors from "cors";

dotenv.config();

const app = express();
app.use(cors());
app.use(bodyParser.json());

const client = new OpenAI({
  apiKey: process.env.OPENAI_API_KEY,
});

// Route for the AI call
app.post("/api/ask", async (req, res) => {
  console.log("✅ /api/ask route hit");
  const { userPrompt, userCode } = req.body;

  try {
    const completion = await client.chat.completions.create({
      model: "gpt-4o-mini", // or "gpt-4.1-mini", "gpt-4o", etc.
      messages: [
        {
          role: "system",
          content: "You are a helpful AI coding assistant. Keep your answers under 200 words."
        },
        { role: "user", content: `Code:\n${userCode}\n\nQuestion: ${userPrompt}` },
      ],
      max_completion_tokens: 300 // ✅ renamed parameter
    });

    res.json({ reply: completion.choices[0].message.content });
  } catch (error) {
    console.error("❌ OpenAI API Error:", error);
    res.status(500).json({ error: error.message });
  }
});

const PORT = process.env.PORT || 3000;

import path from "path";
import { fileURLToPath } from "url";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

app.use(express.static(path.join(__dirname, "public")));

app.listen(PORT, () => {
  console.log(`🚀 Server running on port ${PORT}`);
});
