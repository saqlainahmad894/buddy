<p align="center">
  <img src="docs/promo/buddy_github_banner.png" alt="Buddy — companion for your day and deen" width="100%" />
</p>

# Buddy

**A calm, offline-first companion for your day and deen.**

Buddy helps you check in, build gentle habits, stay near salah, and keep a private journal — on your phone, without requiring an account or a paid backend.

Your connection with Allah stays direct. Buddy only supports the routine.

---

## Features

- **Chat companion** — text, voice notes, and photo check-ins with warm, friend-like replies
- **Focus** — habits + discipline goals with streaks and soft reminders
- **Salah** — offline prayer times, next-prayer countdown, configurable reminders
- **Journal** — private reflections stored on-device
- **Care signals** — day/evening check-ins, scenery breaks, scroll pause, journal nudges (times you choose)
- **Optional Gemini** — paste your own free API key for smarter chats; offline mode always works
- **Dark mode** — night-friendly UI
- **Privacy-first** — local Hive storage, no account required

---

## Screenshots

| 1 | 2 | 3 |
| :---: | :---: | :---: |
| <img src="docs/screenshots/screen-01.png" width="220" alt="Screenshot 1" /> | <img src="docs/screenshots/screen-02.png" width="220" alt="Screenshot 2" /> | <img src="docs/screenshots/screen-03.png" width="220" alt="Screenshot 3" /> |

| 4 | 5 | 6 |
| :---: | :---: | :---: |
| <img src="docs/screenshots/screen-04.png" width="220" alt="Screenshot 4" /> | <img src="docs/screenshots/screen-05.png" width="220" alt="Screenshot 5" /> | <img src="docs/screenshots/screen-06.png" width="220" alt="Screenshot 6" /> |

| 7 | 8 | 9 |
| :---: | :---: | :---: |
| <img src="docs/screenshots/screen-07.png" width="220" alt="Screenshot 7" /> | <img src="docs/screenshots/screen-08.png" width="220" alt="Screenshot 8" /> | <img src="docs/screenshots/screen-09.png" width="220" alt="Screenshot 9" /> |

| 10 | 11 | 12 |
| :---: | :---: | :---: |
| <img src="docs/screenshots/screen-10.png" width="220" alt="Screenshot 10" /> | <img src="docs/screenshots/screen-11.png" width="220" alt="Screenshot 11" /> | <img src="docs/screenshots/screen-12.png" width="220" alt="Screenshot 12" /> |

---

## Run locally

> On Windows, prefer a path **without spaces** (e.g. `C:\dev\buddy`) for reliable Android builds.

```bash
cd C:\dev\buddy
flutter pub get
flutter run
```

### Optional: regenerate icons / splash

```bash
dart run flutter_launcher_icons
dart run flutter_native_splash:create
```

---

## Setup tips

1. Allow **notifications** when prompted  
2. **Settings → City preset** for accurate salah times  
3. Turn on **Prayer reminders** and **Care signals**, then set your times  
4. (Optional) Add a free **Gemini API key** for smarter replies  

---

## Stack

- Flutter / Dart  
- Provider + Hive (local state & storage)  
- `adhan` (offline prayer times)  
- `flutter_local_notifications`  
- Optional Google Gemini via user-supplied key  

---

## Privacy

- Chat, journal, habits, goals, and photos stay on the device  
- No Buddy cloud backend  
- Online AI (if enabled) only runs when you provide your own key  

---

## License

This project is licensed under the **MIT License** — see the [LICENSE](LICENSE) file.

That means others **can use, copy, and modify** Buddy, as long as they **keep your copyright notice** (they can’t strip credit from the license / attribution). They cannot claim there was no license or remove your name from the MIT notice that must stay with the code.

### How this was set up (for you / future repos)

1. Create a file named `LICENSE` in the repo root (GitHub recognizes this name).
2. Paste an MIT (or other) license text with your copyright year + name.
3. On GitHub: **Repo → About (gear) → License** will usually auto-detect MIT after you push `LICENSE`.
4. Or: **Add file → Create new file →** type `LICENSE` → GitHub’s license picker → choose **MIT** → commit.

To show the license badge on the README (optional):

```md
[![License: MIT](https://img.shields.io/badge/License-MIT-teal.svg)](LICENSE)
```

---

<p align="center">
  <b>Buddy</b> · Companion for your day & deen
</p>
