---
name: arc-review-management
description: |
  HEAR framework for responding to App Store reviews. Drafts empathetic,
  actionable, public responses to 1–3 star reviews and templates for 4–5 star
  acknowledgments. Use when "respond to App Store review", "reply to review",
  "review response", "negative review", or "App Store feedback".
user-invocable: true
metadata:
  author: ARC Labs Studio
  version: "1.0.0"
---

# arc-review-management — App Store Review Responses

## Instructions

### The HEAR Framework

All responses follow HEAR:
- **H**ear — Acknowledge the user's experience without being defensive
- **E**mpathize — Show genuine understanding of their frustration
- **A**ct — State what was done or will be done
- **R**esolve — Offer a path to resolution (email, update, workaround)

### Step 1: Analyze the review

Parse the review for:
- **Type**: Bug report | Feature request | Confusion | Price complaint | Competitor comparison
- **Sentiment**: 1★ angry, 2★ frustrated, 3★ mixed, 4–5★ positive
- **Specificity**: Vague complaint vs specific bug with steps

### Step 2: Response by type

**Bug Report (1–2★)**
```
Hi [name or "there"], thank you for reporting this. We're sorry [app name]
isn't working as expected — [acknowledge specific issue they mentioned].

Our team is looking into this. If you'd like to help us reproduce it faster,
please reach out at [support email] with your device and iOS version.

We'll notify you when a fix is available. Thank you for helping us improve!
— [Studio Name]
```

**Feature Request (3★)**
```
Hi, thanks for taking the time to share this! [Feature] is something we're
actively thinking about. We'd love to hear more about how you'd use it —
reach us at [email].

We're working on updates that we think you'll enjoy. Appreciate your
continued support!
— [Studio Name]
```

**Confusion / UX issue (2–3★)**
```
Hi, thanks for the feedback! We're sorry [feature] wasn't clear. Here's
a quick tip: [one-sentence explanation or workaround].

We're working on making this more intuitive in an upcoming update. If you
have more questions, we're happy to help at [email].
— [Studio Name]
```

**Positive review (4–5★)**
```
Thank you so much for the kind words! We're thrilled [app] is helping you
[their use case]. It means a lot to our small team. Reviews like yours
keep us going!
— [Studio Name]
```

### Step 3: Response rules

- Max 200 words (App Store truncates long responses)
- Never be defensive or argue
- Never promise a specific release date
- Always end with a human touch (team size, gratitude)
- Use the user's name if they used it in the review
- Never copy-paste the same response to multiple reviews

### Step 4: Escalation for 1★ with personal attack

Do not respond publicly to reviews that contain hate speech or personal attacks. Instead, report to Apple: App Store Connect → Reviews → Report a Concern.

### Output

Provide a ready-to-paste response:

```
## Review Response Draft

Review: [paste user review]
Type: [Bug/Feature/Confusion/Positive]
Tone: [Empathetic/Grateful/Helpful]

Response (XX words):
---
[Draft response]
---

Personalization notes:
- [Any specific detail addressed]
- [What was not addressed and why]
```
