# Claude Code v2.0.0 - Demo Video Production Package

This directory contains everything you need to create a professional demo video for Claude Code v2.0.0.

---

## 📁 Contents

| File | Description | Use Case |
|------|-------------|----------|
| **VIDEO_STORYBOARD.md** | Complete storyboard with 11 scenes, timing, and visual details | Main reference for video structure |
| **VIDEO_RECORDING_COMMANDS.sh** | Executable script with all terminal commands | Run during screen recording |
| **VIDEO_VOICEOVER_SCRIPT.txt** | Full voiceover script with pronunciation and timing | Read during audio recording |
| **VIDEO_PRODUCTION_GUIDE.md** | Step-by-step production guide (pre to post) | Follow for complete workflow |
| **README.md** | This file - quick start guide | Start here |

---

## 🚀 Quick Start (3 Steps)

### 1. Review Materials (15 minutes)
```bash
# Read storyboard
cat VIDEO_STORYBOARD.md | less

# Review voiceover script
cat VIDEO_VOICEOVER_SCRIPT.txt | less

# Study production guide
cat VIDEO_PRODUCTION_GUIDE.md | less
```

### 2. Setup Environment (30 minutes)
- Install OBS Studio: https://obsproject.com/
- Install DaVinci Resolve: https://www.blackmagicdesign.com/products/davinciresolve
- Install Audacity: https://www.audacityteam.org/
- Configure terminal (font size 16, high contrast theme)
- Test microphone and recording software

### 3. Record & Produce (4-6 hours)
```bash
# Make recording script executable
chmod +x VIDEO_RECORDING_COMMANDS.sh

# Option A: Run automated demo
bash VIDEO_RECORDING_COMMANDS.sh

# Option B: Use commands manually during OBS recording
# Follow VIDEO_STORYBOARD.md scene by scene

# Then follow VIDEO_PRODUCTION_GUIDE.md for:
# - Voiceover recording
# - Video editing
# - Export & publish
```

---

## 📊 Video Specifications

| Property | Value |
|----------|-------|
| **Total Duration** | 3:40 (3 minutes 40 seconds) |
| **Resolution** | 1920×1080 (1080p) |
| **Frame Rate** | 30 fps |
| **Format** | MP4 (H.264) |
| **Scenes** | 11 major sections |
| **Audio** | 44.1 kHz, Stereo, -14 LUFS |

---

## 🎬 Production Workflow

```
┌──────────────────┐
│  Pre-Production  │  ← VIDEO_PRODUCTION_GUIDE.md (Phase 1)
│   (30 minutes)   │
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│ Screen Recording │  ← VIDEO_RECORDING_COMMANDS.sh
│   (1-2 hours)    │  ← VIDEO_STORYBOARD.md
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│    Voiceover     │  ← VIDEO_VOICEOVER_SCRIPT.txt
│    (1 hour)      │  ← Audacity processing
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│  Video Editing   │  ← DaVinci Resolve
│   (2-3 hours)    │  ← Add titles, annotations
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│ Export & Publish │  ← YouTube, Reddit, Twitter
│   (30 minutes)   │  ← GitHub, Hacker News
└──────────────────┘
```

---

## 🎯 Scene Breakdown

| Scene | Title | Duration | Key Content |
|-------|-------|----------|-------------|
| 1 | Opening Title | 0:10 | Branding, stats, intro |
| 2 | Installation | 0:20 | Lazy.nvim config |
| 3 | Basic Usage | 0:20 | Terminal toggle, commands |
| 4 | Multi-Instance | 0:30 | Polyrepo demo, switching |
| 5 | AI Analysis | 0:30 | Code quality review |
| 6 | Optimization | 0:25 | Performance improvements |
| 7 | Test Generation | 0:20 | Automated test scaffolding |
| 8 | Security | 0:20 | 7 security features |
| 9 | Team Profiles | 0:20 | Role-based configs |
| 10 | Documentation | 0:15 | 8 comprehensive guides |
| 11 | Closing | 0:30 | Summary, CTA |

**Total**: 3:40

---

## 🛠️ Required Software

### Free (Recommended)

| Software | Purpose | Platform | Download |
|----------|---------|----------|----------|
| **OBS Studio** | Screen recording | Win/Mac/Linux | https://obsproject.com/ |
| **DaVinci Resolve** | Video editing | Win/Mac/Linux | https://www.blackmagicdesign.com/ |
| **Audacity** | Audio recording/editing | Win/Mac/Linux | https://www.audacityteam.org/ |
| **ffmpeg** | Video conversion | Win/Mac/Linux | https://ffmpeg.org/ |

### Optional

| Software | Purpose | Platform |
|----------|---------|----------|
| **asciinema** | Terminal recording | Mac/Linux |
| **Shotcut** | Alternative video editor | Win/Mac/Linux |
| **Voicemeeter** | Audio mixing | Windows |
| **iMovie** | Alternative video editor | Mac |

---

## 💡 Pro Tips

### Recording
1. **Use high contrast theme** - Makes terminal more readable
2. **Font size 16-18** - Ensures text visibility
3. **Type deliberately** - Not too fast, not too slow
4. **Clear terminal history** before each scene
5. **Disable notifications** - No interruptions

### Audio
1. **Record in quiet space** - Minimize background noise
2. **Use pop filter** - Reduces plosives (p, b sounds)
3. **Position mic 6-8 inches away** - Optimal distance
4. **Do warmup exercises** - Better voice quality
5. **Drink water** - Avoid milk/soda before recording

### Editing
1. **Use keyboard shortcuts** - Speeds up editing
2. **Color grade terminal** - Boost contrast and saturation
3. **Duck background music** - Keep voiceover clear
4. **Add annotations** - Highlight key features
5. **Smooth transitions** - 0.5-1 second cross-dissolves

---

## 📐 Technical Specifications

### Terminal Configuration
```lua
-- Neovim settings for recording
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.cursorline = true
vim.opt.termguicolors = true
vim.opt.guifont = "JetBrains Mono:h16"

-- Recommended colorscheme
vim.cmd('colorscheme tokyonight-storm')
```

### OBS Settings
```
Video:
- Base Resolution: 1920×1080
- Output Resolution: 1920×1080
- FPS: 30

Output:
- Recording Format: MP4
- Video Bitrate: 6000 Kbps
- Encoder: x264 or NVENC
- Audio Bitrate: 320 Kbps
```

### DaVinci Resolve Export
```
Format: MP4
Codec: H.264
Resolution: 1920×1080
Frame Rate: 30 fps
Bitrate: 15,000 Kb/s
Audio: AAC, 320 Kb/s, 48 kHz
```

---

## 🎵 Music & Assets

### Royalty-Free Music
- **YouTube Audio Library**: https://www.youtube.com/audiolibrary
- **Free Music Archive**: https://freemusicarchive.org/
- **Incompetech**: https://incompetech.com/music/royalty-free/

### Fonts
- **JetBrains Mono**: https://www.jetbrains.com/lp/mono/ (terminal)
- **Fira Code**: https://github.com/tonsky/FiraCode (terminal)
- **Montserrat**: https://fonts.google.com/specimen/Montserrat (titles)

### Color Schemes
- **Catppuccin Mocha**: https://github.com/catppuccin/nvim
- **Tokyo Night Storm**: https://github.com/folke/tokyonight.nvim
- **Nord**: https://github.com/nordtheme/vim

---

## 📤 Publishing Checklist

### Video Upload
- [ ] Exported final video (MP4, 1080p)
- [ ] Created GIF version for README (30 seconds)
- [ ] Uploaded to YouTube
- [ ] Added title, description, tags
- [ ] Created eye-catching thumbnail (1280×720)
- [ ] Added timestamps to description
- [ ] Enabled captions/subtitles

### Distribution
- [ ] Shared on Reddit (r/neovim, r/vim)
- [ ] Shared on Twitter/X
- [ ] Posted on Hacker News
- [ ] Added to GitHub README.md
- [ ] Announced in GitHub Discussions
- [ ] Updated plugin documentation

---

## 🎬 Alternative Formats

### Short Version (30 seconds)
Perfect for Twitter/X, focuses on installation → toggle → AI analysis

**Create with**:
```bash
ffmpeg -i full-demo.mp4 -ss 00:00:10 -t 00:00:30 \
  -vf "scale=1280:720" short-demo.mp4
```

### GIF for README (15 seconds loop)
Shows basic workflow in animated GIF

**Create with**:
```bash
ffmpeg -i full-demo.mp4 -ss 00:00:30 -t 00:00:15 \
  -vf "fps=10,scale=800:-1:flags=lanczos,split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse" \
  demo-preview.gif
```

### Tutorial Series (5×5 minutes)
Longer format covering each feature in depth

---

## ⏱️ Time Estimates

| Task | Estimated Time |
|------|----------------|
| **Review materials** | 15 minutes |
| **Setup software & environment** | 30 minutes |
| **Screen recording** | 1-2 hours |
| **Voiceover recording** | 1 hour |
| **Video editing** | 2-3 hours |
| **Export & publish** | 30 minutes |
| **TOTAL** | 5-7 hours |

*First-time producers: Add 2-3 hours for learning curve*

---

## 🆘 Troubleshooting

### Common Issues

**"Text is blurry in the video"**
- Increase terminal font size to 16-18
- Export at higher bitrate (20,000 Kb/s)
- Use crisp fonts (JetBrains Mono, Fira Code)

**"Audio has background noise"**
- Record in quieter environment
- Apply noise reduction in Audacity
- Use noise gate effect

**"Video file is too large"**
- Reduce bitrate to 10,000 Kb/s
- Use H.265 codec (smaller files)
- Compress with HandBrake

**"Render takes forever"**
- Use hardware encoding (NVENC/QuickSync)
- Generate optimized media in Resolve
- Lower resolution for preview renders

---

## 💬 Support & Feedback

**Questions?**
- Open an issue: https://github.com/anthropics/claude-code.nvim/issues
- Start a discussion: https://github.com/anthropics/claude-code.nvim/discussions

**Share Your Video!**
- Tag us on Twitter: @ClaudeCode (if applicable)
- Post in r/neovim with [Video] flair
- We'll feature community videos in README!

---

## 📝 Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2025-01-07 | Initial video production package |

---

## 📄 License

These production materials are provided under the same MIT license as the claude-code.nvim plugin.

You are free to:
- Create videos using these materials
- Modify scripts for your needs
- Share your videos publicly
- Use for commercial purposes

---

## 🙏 Credits

**Storyboard & Script**: Created for claude-code.nvim v2.0.0 release
**Music**: Use royalty-free sources (see Music & Assets section)
**Software**: OBS Studio, DaVinci Resolve, Audacity (all free)

---

## 🚀 Ready to Start?

1. Read **VIDEO_STORYBOARD.md** - Understand the full vision
2. Study **VIDEO_PRODUCTION_GUIDE.md** - Learn the workflow
3. Practice with **VIDEO_RECORDING_COMMANDS.sh** - Test your setup
4. Record your demo! 🎬

**Good luck with your video production!**

Questions? Open an issue or discussion on GitHub!
