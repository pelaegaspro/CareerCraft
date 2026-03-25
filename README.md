# ✦ CareerCraft AI

> **Build your career website, resume, LinkedIn summary, and cover letter — all with one AI prompt.**

CareerCraft is a Manus-style AI career builder powered by Claude. It runs entirely in the browser — no server, no install, no framework. Just open `index.html` and go.

---

## 🚀 Live Demo

Open `index.html` in any browser. Works offline after first load (fonts need internet).

---

## ⚡ Quick Start

```bash
# 1. Clone the repo
git clone https://github.com/YOUR_USERNAME/careercraft.git
cd careercraft

# 2. Open in browser
open index.html
# or just double-click index.html
```

Then:
1. Paste your **Anthropic API key** (`sk-ant-api03-…`) in the key bar
2. Click **Save**
3. Pick a starting action or describe yourself in the text box
4. Get your complete career website, resume, LinkedIn summary, or cover letter instantly

---

## ✨ Features

| Feature | Description |
|--------|-------------|
| 🌐 **Website Builder** | Generates a complete, copy-paste HTML career site with Hero, About, Skills, Experience, Projects, Contact |
| 📄 **Resume Rewriter** | STAR method bullets, action verbs, quantified results |
| 💼 **LinkedIn Summary** | 3-paragraph magnetic About section |
| ✉️ **Cover Letter** | Tailored, specific, compelling |
| 🎯 **Interview Prep** | 10 role-specific questions with model answers |

---

## 🧠 The System Prompt

The full system prompt powering CareerCraft is embedded in `index.html`. It instructs Claude to:

- **Never** use placeholders — always use real info
- Output **100% complete** HTML in a single code block
- Follow a strict website structure (Hero → About → Skills → Experience → Projects → Contact)
- Use dark theme with neon accents, animations, mobile responsive design
- Deliver end-to-end like Manus — no partial outputs

---

## 🗂 Project Structure

```
careercraft/
├── index.html      ← Entire app (HTML + CSS + JS + System Prompt)
└── README.md       ← This file
```

Single file. No dependencies. No build step.

---

## 🔑 API Key

You need an [Anthropic API key](https://console.anthropic.com).

- Keys are saved to `localStorage` — they stay in your browser
- Never committed to git
- Free tier works for testing; standard pricing for heavy use

---

## 🛠 Tech Stack

- **Vanilla HTML/CSS/JS** — zero dependencies
- **Claude claude-sonnet-4-20250514** via Anthropic REST API
- **Google Fonts** — Syne + DM Sans + Fira Code
- **CSS animations** — orbs, shimmer, bounce, fade-up

---

## 🎨 Customization

To change the accent color, edit the CSS variables at the top of `index.html`:

```css
:root {
  --v:  #7c3aed;   /* Primary violet */
  --v2: #9333ea;
  --v3: #a855f7;
  --v4: #c084fc;
}
```

Swap for cyan (`#06b6d4`), emerald (`#10b981`), or any color.

---

## 📋 One-Copy-Paste System Prompt

Use this prompt in **any** AI tool (ChatGPT, Gemini, Manus, etc.):

```
You are CareerCraft AI — an elite career strategist, resume writer, and personal website builder. You operate like Manus: autonomous, thorough, and end-to-end. You never deliver partial outputs.

WHAT YOU BUILD:
1. FULL CAREER WEBSITE — Complete single-file HTML (no placeholders, real content only)
2. RESUME REWRITE — STAR method, powerful action verbs, quantified results
3. LINKEDIN SUMMARY — 3-paragraph magnetic About section
4. COVER LETTER — Tailored, specific, compelling
5. INTERVIEW PREP — 10 likely questions with ideal structured answers

STRICT RULES:
- NEVER use placeholders like [Your Name], [Company], [Add here]
- Ask 2-3 targeted questions ONLY if critical info is missing
- For websites: output 100% complete HTML in a single ```html code block
- Be specific, bold, confident. Deliver complete work every time.

WEBSITE MUST INCLUDE:
• Hero — Full name, title, animated tagline, CTA button
• About — 4-sentence bio
• Skills — Visual badge grid
• Experience — Timeline with company, role, dates, 3 STAR bullets each
• Projects — Cards with title, description, tech stack, links
• Education — Degree, school, year
• Contact — Email, LinkedIn, GitHub, form
• Footer

DESIGN: Dark theme (#0a0a0f), neon accent color, Google Fonts (Syne headings), smooth scroll, CSS animations, mobile responsive, glassmorphism cards.

OUTPUT FORMAT:
1. One-line summary of what you built
2. Full HTML in a ```html block
3. 3 suggested next upgrades
```

---

## 📄 License

MIT — free to use, fork, and build on.

---

Made with ✦ and Claude AI
