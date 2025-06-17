# 🧠 PAI – Prompt Aggregation for Inference

> **Automate the grunt-work of turning a whole codebase into one perfect LLM prompt**

---

## Table of Contents

1. [Why PAI Exists](#1-why-pai-exists)
2. [Quick Start (TL;DR)](#2-quick-start-tldr)
3. [Repository Layout](#3-repository-layout)
4. [Sample Files & Output](#4-sample-files--output)
5. [Installation & Keeping PAI out of Git](#5-installation--keeping-pai-out-of-git)
6. [Configuration Deep-Dive (`pai_config.sh`)](#6-configuration-deep-dive-paiconfigsh)
7. [How `pai.sh` Works (Pipeline)](#7-how-paish-works-pipeline)
8. [Include / Exclude Engine — Caveats](#8-include--exclude-engine--caveats)
9. [Dependencies](#9-dependencies)
10. [Troubleshooting](#10-troubleshooting)
11. [Roadmap](#11-roadmap)
12. [License](#12-license)

---

## 1. Why PAI Exists

Large-language models thrive on **focused context**.  
Copy-pasting random snippets wastes tokens, loses structure, and derails your flow.  
PAI compresses everything you need into **one single text file**:

| Section in `pai.output.txt`      | What it contains                                            |
| -------------------------------- | ----------------------------------------------------------- |
| `--- Prompt ---`                 | Global directives (style, rules, etc.)                      |
| `--- Details ---`                | Session-specific context (the “story so far”)               |
| `--- Folder Structure ---`       | A pretty tree of only the relevant folders                  |
| `--- Baseline File Contents ---` | Every source file you care about, comment-stripped and tidy |

Hand that file to any model—ChatGPT, Claude, Gemini, whatever—and you’re rolling in seconds.

---

## 2. Quick Start (TL;DR)

```bash
# 1 · Add PAI to your project .gitignore
echo '**/.pai/' >> .gitignore

# 2 · Clone PAI into a hidden folder
git clone https://github.com/moztopia/pai .pai

# 3 · (Optionally) Tweak filters in .pai/pai_config.sh
(edit this file ---->) .pai/pai_config.sh

# 4 · Generate the prompt package
cd .pai
chmod +x pai.sh
./pai.sh

# 5 · Copy-paste .pai/pai.output.txt into your LLM chat window
```

---

## 3. Repository Layout

```
.pai/                  # Suggested location (kept out of main repo)
├── pai.sh             # 🏃 run this
├── pai_config.sh      # ⚙️  env vars only; dies if run directly
├── pai.prompt.txt     # 🌐 global AI directives
├── pai.details.txt    # 🎯 session-specific context
├── examples/          # 📂 sample input & output
└── README.md          # 📖 you are here
```

---

## 4. Sample Files & Output

<details>
<summary>pai.prompt.txt</summary>

```text
Flutter/Dart Project (android/linux/ios/windows/macos targets)
Do not put comments in my code.
Do not write code unless I ask for it.
Be brief and concise.
Your function in this is help and not as a teacher.
Think ... code monkey.
```

</details>

<details>
<summary>pai.details.txt</summary>

```text
We are going to try and strip the token from the webView as a pre-navigation
process and then abort the redirect navigation request. This will eliminate the
need to work with schemes and help to unify our code across all platforms.
```

</details>

<details>
<summary>Generated pai.output.txt (truncated)</summary>

--- Prompt ---
Flutter/Dart Project … Think ... code monkey.

--- Details ---
We are going to try and strip the token from the webView …

--- Folder Structure ---
/home/mozrin/Code/assets/
└── languages/

2 directories, 0 files

/home/mozrin/Code/lib/
├── everything.dart
├── main.dart
├── screens/
…
27 directories, 53 files

--- Baseline File Contents ---

/home/mozrin/Code/lib/main.dart

import 'package:flutter/material.dart';
…

</details>

---

## 5. Installation & Keeping PAI out of Git

1. **Ignore it**

   ```bash
   echo '**/.pai/' >> .gitignore
   ```

2. **Clone into that ignored folder**
   ```bash
   git clone https://github.com/moztopia/pai .pai
   ```
3. **Why the leading dot?**
   It shoves PAI to the top of your project tree, keeps it hidden, and makes sure it never sneaks into production builds or blends into your production folders.

---

## 6. Configuration Deep-Dive (`pai_config.sh`)

| Variable        | Description / Example                                                                  |
| --------------- | -------------------------------------------------------------------------------------- |
| `PAI_DIR`       | Where prompt, detail, and output files live (default: current directory).              |
| `CODE_DIR`      | Optional pointer to your real code root.                                               |
| `OUTPUT_FILE`   | Final aggregated file (default: `$PAI_DIR/pai.output.txt`).                            |
| `PROMPT_FILE`   | Global directives path (`pai.prompt.txt`).                                             |
| `DETAILS_FILE`  | Session context path (`pai.details.txt`).                                              |
| `ROOT_FOLDERS`  | Pipe-separated list of folders to scan, e.g.:<br>`$PAI_DIR/../assets\|$PAI_DIR/../lib` |
| `INCLUDE_EXTS`  | Extensions to keep, e.g. `dart\|yaml\|json`.                                           |
| `EXCLUDE_DIRS`  | Directory names to ignore, e.g. `build\|ios\|android\|.git\|test\|…`.                  |
| `EXCLUDE_FILES` | Filenames (regex) to drop, e.g. `package-lock.json\|\*.generated.dart`.                |

> **Heads-up:** the include/exclude engine is _functional_ but **not battle-tested** on every project type. Verify the output before feeding it to mission-critical prompts.

---

## 7. How `pai.sh` Works (Pipeline)

| Step | What happens                                                                                                                                                                                                                   |
| ---- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| 1    | `source pai_config.sh`.                                                                                                                                                                                                        |
| 2    | Wipe/initialise `pai.output.txt`.                                                                                                                                                                                              |
| 3    | Append `--- Prompt ---` section from `pai.prompt.txt`.                                                                                                                                                                         |
| 4    | Append `--- Details ---` section from `pai.details.txt`.                                                                                                                                                                       |
| 5    | **Folder tree:**<br>• If `tree` exists → `tree -F -P "*.$INCLUDE_EXTS" -I "$EXCLUDE_DIRS"`.<br>• Else → manual `find` + `grep` fallback.                                                                                       |
| 6    | **File sweep:**<br>• `find` every file matching `INCLUDE_EXTS`.<br>• Skip `EXCLUDE_DIRS` and `EXCLUDE_FILES`.<br>• Strip `/* … */` and `// ...` comments, trim whitespace.<br>• Prepend each file with `# /full/path/to/file`. |
| 7    | Echo `Generated /path/to/pai.output.txt`.                                                                                                                                                                                      |

All heavy lifting sits in one script for now; modular refactor is on the roadmap.

---

## 8. Include / Exclude Engine — Caveats

- Regexes are **OR-joined**, not AND-joined.
- Exclude patterns run **after** extension filtering.
- Multiline comment removal is naïve—edge-cases (nested comments, strings) may slip.
- Pull Requests welcome!

---

## 9. Dependencies

| Tool   | Purpose                   | Install (Ubuntu)        | Notes                                   |
| ------ | ------------------------- | ----------------------- | --------------------------------------- |
| `tree` | Pretty directory diagrams | `sudo apt install tree` | Optional; fallback to `find` if missing |
| `bash` | Script runtime            | Comes with every distro | Tested on Bash 5+                       |

No other external binaries are required.

---

## 10. Troubleshooting

| Symptom                                               | Fix                                                               |
| ----------------------------------------------------- | ----------------------------------------------------------------- |
| `pai_config.sh: This script is meant to be included…` | You tried to `./pai_config.sh`. Run `pai.sh` instead.             |
| `tree: command not found`                             | `sudo apt install tree` (or ignore; fallback will trigger).       |
| File you wanted is missing                            | Check `INCLUDE_EXTS` / `EXCLUDE_DIRS` / `EXCLUDE_FILES` patterns. |
| Output still huge                                     | Tighten your filters, or add token budgeting to roadmap!          |

---

## 11. Roadmap

- Modular config file (pull env vars out of `pai.sh`).
- Smarter comment stripper (keep docstrings, ditch noise).
- Token-budget estimator (`wc -w`, token heuristics).
- Unit tests for filter engine.
- Cross-platform checks (macOS Homebrew, Windows Git Bash).

---

## 12. License

MIT—do what you want, just don’t blame me if your AI hallucinates.
See [LICENSE](LICENSE) for full text.

**Made with caffeine & curiosity.**
If PAI speeds up your workflow, drop a ⭐️ or open an issue with ideas!
