# Claude Code v2.0.0 - Video Production Guide

## Quick Start

This guide walks you through creating a professional demo video for Claude Code v2.0.0.

**Time Required**: 4-6 hours (including recording, editing, and rendering)
**Skill Level**: Beginner to Intermediate
**Budget**: $0 (using free tools)

---

## Phase 1: Pre-Production (30 minutes)

### 1.1 Install Required Software

**Video Recording**:
- **OBS Studio** (Free): https://obsproject.com/
- **asciinema** (Terminal recording): https://asciinema.org/
- **Windows Game Bar** (Windows built-in): Win+G

**Video Editing**:
- **DaVinci Resolve** (Free): https://www.blackmagicdesign.com/products/davinciresolve
- **Shotcut** (Free alternative): https://shotcut.org/
- **iMovie** (Mac built-in): Included with macOS

**Audio Recording**:
- **Audacity** (Free): https://www.audacityteam.org/
- **Voicemeeter** (Audio mixing - Windows): https://vb-audio.com/Voicemeeter/

### 1.2 Setup Your Environment

```bash
# Clone repository
git clone https://github.com/anthropics/claude-code.nvim
cd claude-code.nvim

# Navigate to video resources
cd video

# Make scripts executable
chmod +x VIDEO_RECORDING_COMMANDS.sh

# Review materials
cat VIDEO_STORYBOARD.md          # Full storyboard
cat VIDEO_VOICEOVER_SCRIPT.txt   # Voiceover script
```

### 1.3 Configure Terminal for Recording

**Neovim Configuration**:
```lua
-- Recommended settings for recording
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.signcolumn = "yes"
vim.opt.cursorline = true
vim.opt.termguicolors = true
vim.opt.showmode = false  -- Disable -- INSERT -- message

-- Large, readable font
vim.opt.guifont = "JetBrains Mono:h16"
```

**Terminal Configuration**:
- **Font**: JetBrains Mono Nerd Font or Fira Code (size 14-18)
- **Color Scheme**: High contrast (Catppuccin Mocha, Tokyo Night Storm, Nord)
- **Resolution**: 1920x1080 minimum
- **Window Size**: 180 columns × 45 rows (approximately)
- **Cursor**: Block style, blinking enabled

**Theme Recommendations**:
```bash
# For Neovim
:colorscheme tokyonight-storm
:colorscheme catppuccin-mocha
:colorscheme nord

# Or install via plugin manager
```

---

## Phase 2: Screen Recording (1-2 hours)

### 2.1 OBS Studio Setup

**Scene Configuration**:

1. **Create New Scene**: "Claude Code Demo"

2. **Add Display Capture Source**:
   - Right-click → Add → Display Capture
   - Name: "Terminal Window"
   - Select: Your terminal/Neovim window

3. **Configure Video Settings** (Settings → Video):
   - Base Resolution: 1920x1080
   - Output Resolution: 1920x1080
   - FPS: 30

4. **Configure Output** (Settings → Output):
   - Output Mode: Simple
   - Video Bitrate: 6000 Kbps
   - Encoder: x264 (CPU) or NVENC (GPU if available)
   - Recording Format: MP4
   - Recording Quality: High Quality

5. **Configure Audio** (Settings → Audio):
   - Sample Rate: 44.1 KHz
   - Channels: Stereo
   - Desktop Audio: Disabled (we'll add voiceover later)
   - Mic/Auxiliary Audio: Disabled (separate voiceover)

### 2.2 Recording the Screen Content

**Option A: Manual Recording with OBS**

1. Open OBS Studio
2. Position Neovim/terminal window
3. Click "Start Recording"
4. Follow the storyboard section by section
5. Execute commands from VIDEO_RECORDING_COMMANDS.sh
6. Click "Stop Recording" when done

**Option B: Automated asciinema Recording**

```bash
# Install asciinema
# macOS:
brew install asciinema

# Linux:
sudo apt install asciinema

# Record terminal session
asciinema rec demo.cast

# Follow the script, then Ctrl+D to stop

# Convert to GIF (for README)
npm install -g asciicast2gif
asciicast2gif demo.cast demo.gif

# Convert to video
docker run --rm -v $PWD:/data asciinema/asciicast2gif \
  /data/demo.cast /data/demo.mp4
```

**Option C: Script-Driven Recording**

```bash
# Run the automated demo script
bash VIDEO_RECORDING_COMMANDS.sh

# Record with OBS while script runs
# This provides consistent timing
```

### 2.3 Recording Tips

**Before Each Take**:
- [ ] Clear terminal history: `clear`
- [ ] Reset demo directory: `rm -rf ~/claude-code-demo-video`
- [ ] Close unnecessary applications
- [ ] Disable notifications (Do Not Disturb mode)
- [ ] Check window positioning
- [ ] Verify color scheme visibility

**During Recording**:
- Type deliberately (not too fast, not too slow)
- Pause 1-2 seconds between major actions
- If you make a mistake, pause 3 seconds and redo from previous section
- Keep cursor movements smooth and purposeful
- Avoid unnecessary mouse hovering

**Quality Checks**:
- [ ] Text is clearly readable
- [ ] Colors have good contrast
- [ ] No screen tearing or flickering
- [ ] Smooth transitions between commands
- [ ] No personal information visible

---

## Phase 3: Voiceover Recording (1 hour)

### 3.1 Audacity Setup

1. **Open Audacity**
2. **Configure Audio Host** (Edit → Preferences → Devices):
   - Host: WASAPI (Windows) / Core Audio (Mac) / ALSA (Linux)
   - Recording Device: Your USB microphone
   - Recording Channels: 1 (Mono)

3. **Set Project Rate**: 44100 Hz (bottom left)

4. **Input Levels**:
   - Speak normally and adjust input volume
   - Peak levels should hit -12 to -6 dB (green/yellow zone)
   - Never reach 0 dB (red zone - clipping)

### 3.2 Recording Voiceover

**Preparation**:
```
1. Drink water (avoid milk/soda before recording)
2. Warm up voice (hum, scales, tongue twisters)
3. Practice read-through of script
4. Position microphone 6-8 inches from mouth
5. Angle mic slightly off-axis to reduce plosives
```

**Recording Process**:

1. **Record Room Tone** (15 seconds of silence):
   - Click record
   - Sit silently for 15 seconds
   - Click stop
   - Label this track "Room Tone"

2. **Record Voiceover**:
   - Click record
   - Follow VIDEO_VOICEOVER_SCRIPT.txt
   - Speak clearly at 150 words/minute pace
   - Pause 2-3 seconds between sections
   - If you make a mistake, pause 3 seconds and repeat
   - Complete the full script

3. **Record Backup Takes**:
   - Record sections 5, 6, 8, 11 again (critical sections)
   - Save these as alternate takes

### 3.3 Audio Post-Processing

**Audacity Processing Chain**:

1. **Noise Reduction**:
   - Select "Room Tone" section
   - Effect → Noise Reduction → Get Noise Profile
   - Select entire voiceover track
   - Effect → Noise Reduction → Apply
   - Settings: Noise Reduction: 12 dB, Sensitivity: 6.00

2. **Normalize**:
   - Select all
   - Effect → Normalize
   - Settings: Normalize peak amplitude to -3.0 dB

3. **Compression**:
   - Select all
   - Effect → Compressor
   - Settings:
     - Threshold: -20 dB
     - Noise Floor: -50 dB
     - Ratio: 3:1
     - Attack Time: 0.2 seconds
     - Release Time: 1.0 seconds

4. **Equalization**:
   - Effect → Filter Curve EQ
   - High-pass filter: 80 Hz
   - Presence boost: +3 dB at 5000 Hz (makes voice clearer)

5. **Limiter** (prevents clipping):
   - Effect → Limiter
   - Settings:
     - Type: Hard Limit
     - Input Gain: 0 dB
     - Limit to: -1.0 dB
     - Hold: 10 ms
     - Apply Make-up Gain: Yes

6. **Export**:
   - File → Export → Export Audio
   - Format: WAV (Microsoft) signed 16-bit PCM
   - Sample Rate: 44100 Hz
   - Save as: `voiceover-final.wav`

---

## Phase 4: Video Editing (2-3 hours)

### 4.1 DaVinci Resolve Project Setup

**Create New Project**:
1. Open DaVinci Resolve
2. Create New Project: "Claude Code v2.0.0 Demo"
3. Project Settings (Gear icon):
   - Timeline Format: 1920 × 1080 HD
   - Timeline Framerate: 30 fps
   - Playback Frame Rate: 30 fps
   - Optimize Media and Render Cache: ProRes Proxy (faster editing)

**Import Media**:
1. Go to "Media" page (bottom left)
2. Import your screen recording: `screen-recording.mp4`
3. Import voiceover: `voiceover-final.wav`
4. Import background music (if using)

### 4.2 Basic Edit Timeline

**Cut Page** (for initial rough cut):

1. Drag screen recording to timeline
2. Drag voiceover to audio track
3. Sync voiceover to video:
   - Use claps or visual cues
   - Or use Resolve's Auto-Sync feature
4. Trim video to match voiceover pacing
5. Remove any mistakes or long pauses

**Edit Page** (for detailed editing):

1. **Video Track 1**: Screen recording
2. **Video Track 2**: Title cards, annotations, overlays
3. **Audio Track 1**: Voiceover
4. **Audio Track 2**: Background music
5. **Audio Track 3**: Sound effects (optional)

### 4.3 Add Visual Enhancements

**Title Card** (Scene 1 - Opening):
1. Effects Library → Titles → Fusion Title
2. Drag to timeline at beginning
3. Inspector → Text: "Claude Code v2.0.0"
4. Settings:
   - Font: JetBrains Mono Bold or Montserrat Bold
   - Size: 120
   - Color: #89b4fa (blue) or #f5e0dc (white)
   - Shadow: Enabled
   - Duration: 5 seconds

**Lower Thirds** (for annotations):
1. Effects Library → Titles → Lower Third
2. Customize with:
   - GitHub URL
   - Feature callouts
   - Command demonstrations

**Highlight Annotations**:
1. Effects Library → Effects → Shape → Rectangle
2. Use to highlight:
   - Configuration options
   - Command output
   - Security features
   - Performance metrics

**Transitions**:
- Between scenes: "Cross Dissolve" (0.5-1 second)
- For feature montage: "Dip to Color" (black, 0.25 seconds)
- Opening/closing: "Fade In/Out" (1 second)

### 4.4 Color Grading (Optional but Recommended)

**Color Page**:

1. Select clip
2. Apply basic correction:
   - Lift shadows slightly (+5)
   - Boost mid-tones (+3)
   - Increase saturation (+10)
   - Add sharpness (+20)

3. For terminal footage specifically:
   - Increase contrast (+15)
   - Boost blues/cyans (syntax highlighting)
   - Slightly cool color temperature

### 4.5 Audio Mixing

**Fairlight Page**:

1. **Voiceover (Track 1)**:
   - Level: -6 dB
   - Add EQ: High-pass filter 80Hz
   - Add De-esser (reduce harsh 's' sounds)

2. **Background Music (Track 2)**:
   - Level: -24 dB (background only)
   - Duck under voiceover (sidechain compression):
     - Threshold: -20 dB
     - Ratio: 3:1
     - Release: Fast (music comes back quickly)

3. **Sound Effects (Track 3)** (optional):
   - Whoosh for transitions: -18 dB
   - Click for commands: -22 dB
   - Success sound for completions: -20 dB

4. **Master Output**:
   - Add Limiter: -1 dB ceiling
   - Target LUFS: -14 (YouTube standard)

---

## Phase 5: Export & Publish (30 minutes)

### 5.1 Export Settings (DaVinci Resolve)

**Deliver Page**:

1. **YouTube 1080p Preset** (or custom):
   - Format: MP4
   - Codec: H.264
   - Resolution: 1920 × 1080
   - Frame Rate: 30 fps
   - Quality: Restrict to 15,000 Kb/s
   - Audio: AAC, 320 Kb/s, 48000 Hz

2. **Advanced Settings**:
   - Profile: High
   - Entropy: CABAC
   - Keyframe: Every 30 frames
   - B-frames: 2

3. **Filename**: `claude-code-v2.0.0-demo.mp4`

4. Click "Add to Render Queue"

5. Click "Render All"

**Estimated Render Time**: 5-15 minutes (depends on hardware)

### 5.2 Create GIF Version (for README)

```bash
# Install ffmpeg
# macOS:
brew install ffmpeg

# Ubuntu:
sudo apt install ffmpeg

# Windows:
# Download from https://ffmpeg.org/

# Extract 30-second clip (basic usage section)
ffmpeg -i claude-code-v2.0.0-demo.mp4 -ss 00:00:30 -t 00:00:30 \
  -vf "fps=10,scale=800:-1:flags=lanczos" \
  -c:v gif demo-preview.gif

# Better quality GIF using palette
ffmpeg -i claude-code-v2.0.0-demo.mp4 -ss 00:00:30 -t 00:00:30 \
  -vf "fps=10,scale=800:-1:flags=lanczos,split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse" \
  demo-preview.gif
```

### 5.3 YouTube Upload

**Video Details**:

**Title**:
```
Claude Code v2.0.0 for Neovim - AI-Powered Development with Multi-Instance Support
```

**Description**:
```
Transform your Neovim workflow with Claude Code v2.0.0! This release brings AI-powered development, enterprise-grade security, and multi-repository support directly into your editor.

🚀 KEY FEATURES:
✓ In-Editor Terminal Integration
✓ Multi-Instance Management (per git repository)
✓ AI Code Quality Analysis
✓ AI Performance Optimization
✓ AI Test Generation
✓ Automatic Secret Redaction
✓ Rate Limiting & Size Validation
✓ 99.1% Test Coverage
✓ Zero Breaking Changes

📚 RESOURCES:
• GitHub: https://github.com/anthropics/claude-code.nvim
• Documentation: See config/ directory in repository
• Installation Guide: https://github.com/anthropics/claude-code.nvim#installation
• Team Profiles: https://github.com/anthropics/claude-code.nvim/tree/main/config/team-profiles

⏱️ TIMESTAMPS:
0:00 - Introduction
0:10 - Installation
0:30 - Basic Usage
0:50 - Multi-Instance Management
1:20 - AI Code Analysis
1:50 - Performance Optimization
2:15 - Test Generation
2:35 - Security Features
2:55 - Team Profiles
3:15 - Documentation
3:30 - Summary

💬 COMMUNITY:
• Discussions: https://github.com/anthropics/claude-code.nvim/discussions
• Issues: https://github.com/anthropics/claude-code.nvim/issues

📦 INSTALLATION:
```lua
{
  'anthropics/claude-code.nvim',
  dependencies = { 'nvim-lua/plenary.nvim' },
  config = function()
    require('claude-code').setup({
      ai_integration = { enabled = true },
      git = { multi_instance = true },
    })
  end,
}
```

🎵 MUSIC:
[Credit your music source here]

#neovim #vim #ai #coding #development #claude #developer #productivity
```

**Tags** (max 500 characters):
```
neovim, vim, claude, ai, artificial intelligence, code assistant, developer tools, programming, coding, nvim, lua, plugin, ide, text editor, productivity, multi-instance, security, code review, optimization, testing
```

**Thumbnail**:
- Resolution: 1280 × 720 pixels
- File size: Under 2 MB
- Format: JPG or PNG
- Design: Eye-catching title, key features, high contrast

**Playlist**:
- Create playlist: "Claude Code Tutorials"
- Add this video

**Visibility**:
- Set to "Public" after upload complete
- Enable "Publish to Subscriptions feed and notify subscribers"

### 5.4 Social Media Sharing

**Reddit** - r/neovim, r/vim:
```
Title: [Plugin] Claude Code v2.0.0 - AI-Powered Development with Multi-Instance Support

Body:
I'm excited to share Claude Code v2.0.0 for Neovim! This release brings
AI-powered development directly into your editor.

Key features:
• In-editor terminal integration
• Multi-instance management (per git repo)
• AI code analysis and optimization
• Automatic test generation
• Enterprise-grade security (7 features)
• 99.1% test coverage

Demo video: [YouTube link]
Repository: [GitHub link]

Works with Lazy.nvim, Packer, vim-plug, or manual installation.

Feedback welcome!
```

**Twitter/X**:
```
🚀 Claude Code v2.0.0 for Neovim is here!

✓ AI-powered development
✓ Multi-repo support
✓ Enterprise security
✓ 99.1% test coverage

Watch the demo: [link]

#neovim #vim #ai #coding
```

**Hacker News**:
```
Title: Claude Code v2.0 – AI-powered development for Neovim

URL: [GitHub repository link]

Optional comment:
Creator here. Happy to answer questions about the AI integration,
security features, or multi-instance architecture!
```

---

## Phase 6: Alternative Formats

### 6.1 Short Version (30 seconds - for Twitter/X)

**Content**: Sections 2, 3, 4, 11 only
**Music**: Louder, more energetic
**Pacing**: Faster cuts, quick transitions

### 6.2 Tutorial Series (5 videos × 5 minutes)

1. **Installation & Basic Setup**
2. **Multi-Instance Workflows for Polyrepo**
3. **AI Code Analysis & Optimization**
4. **Security Features Deep Dive**
5. **Team Configuration & Profiles**

### 6.3 Feature Showcase GIFs

Create individual GIFs for each feature:

```bash
# Multi-instance switcher (10 seconds)
ffmpeg -i demo.mp4 -ss 00:00:50 -t 00:00:10 \
  -vf "fps=10,scale=800:-1" multi-instance.gif

# AI analysis (15 seconds)
ffmpeg -i demo.mp4 -ss 00:01:20 -t 00:00:15 \
  -vf "fps=10,scale=800:-1" ai-analysis.gif

# Test generation (10 seconds)
ffmpeg -i demo.mp4 -ss 00:02:15 -t 00:00:10 \
  -vf "fps=10,scale=800:-1" test-generation.gif
```

---

## Troubleshooting

### Video Issues

**Problem**: Text is blurry
- **Solution**: Increase font size to 16-18, use crisp font like JetBrains Mono
- **Solution**: Export at higher bitrate (20,000 Kb/s)

**Problem**: Colors look washed out
- **Solution**: Apply color grading in DaVinci Resolve
- **Solution**: Increase contrast and saturation

**Problem**: Screen tearing
- **Solution**: Enable V-Sync in terminal
- **Solution**: Use higher frame rate (60 fps) for recording

### Audio Issues

**Problem**: Popping/clicking sounds
- **Solution**: Use pop filter on microphone
- **Solution**: Apply de-clicker effect in Audacity

**Problem**: Background noise
- **Solution**: Record in quieter environment
- **Solution**: Apply stronger noise reduction (15 dB)

**Problem**: Voice sounds thin
- **Solution**: Add presence boost at 5 kHz
- **Solution**: Reduce high-pass filter to 60 Hz

### Export Issues

**Problem**: File size too large
- **Solution**: Reduce bitrate to 10,000 Kb/s
- **Solution**: Use H.265 codec instead of H.264

**Problem**: Render takes too long
- **Solution**: Use hardware encoding (NVENC/QuickSync)
- **Solution**: Lower resolution to 720p for preview renders

---

## Resources & Assets

### Free Music Sources (Royalty-Free)

1. **YouTube Audio Library**
   - https://www.youtube.com/audiolibrary
   - Genres: Tech, Corporate, Upbeat

2. **Free Music Archive**
   - https://freemusicarchive.org/
   - Search: "tech" OR "electronic"

3. **Incompetech**
   - https://incompetech.com/music/royalty-free/
   - Recommended: "Carefree", "News Theme 5"

### Sound Effects

1. **Freesound** - https://freesound.org/
   - Whoosh transitions
   - Click sounds
   - Success chimes

2. **Zapsplat** - https://www.zapsplat.com/
   - UI sounds
   - Tech sounds

### Fonts

1. **JetBrains Mono** - https://www.jetbrains.com/lp/mono/
2. **Fira Code** - https://github.com/tonsky/FiraCode
3. **Montserrat** (titles) - https://fonts.google.com/specimen/Montserrat

### Color Schemes

1. **Catppuccin Mocha** - https://github.com/catppuccin/nvim
2. **Tokyo Night Storm** - https://github.com/folke/tokyonight.nvim
3. **Nord** - https://github.com/nordtheme/vim

---

## Checklist - Full Production

### Pre-Production
- [ ] Software installed (OBS, Resolve, Audacity)
- [ ] Terminal configured (font, colors, size)
- [ ] Scripts reviewed and understood
- [ ] Demo environment prepared
- [ ] Recording space set up (quiet, no distractions)

### Recording
- [ ] Screen recording completed (clean, smooth)
- [ ] Voiceover recorded (clear, paced well)
- [ ] Room tone captured for noise reduction
- [ ] Backup takes recorded for critical sections

### Editing
- [ ] Video synced with voiceover
- [ ] Title cards added
- [ ] Annotations/highlights applied
- [ ] Transitions smooth and appropriate
- [ ] Color grading applied
- [ ] Audio mixed and balanced
- [ ] Background music added and ducked

### Export
- [ ] Final video exported (MP4, 1080p, 30fps)
- [ ] GIF version created for README
- [ ] File sizes appropriate (under 500 MB)
- [ ] Quality checked (no artifacts, clear audio)

### Publish
- [ ] YouTube upload complete
- [ ] Description, tags, thumbnail added
- [ ] Timestamps added to description
- [ ] Added to playlist
- [ ] Shared on Reddit (r/neovim, r/vim)
- [ ] Shared on Twitter/X
- [ ] Shared on Hacker News
- [ ] Added to README.md
- [ ] Announced in GitHub Discussions

---

## Estimated Timeline

| Phase | Tasks | Time |
|-------|-------|------|
| **Pre-Production** | Software setup, environment config | 30 min |
| **Screen Recording** | Record all scenes | 1-2 hrs |
| **Voiceover** | Record and process audio | 1 hr |
| **Editing** | Cut, enhance, add effects | 2-3 hrs |
| **Export & Publish** | Render, upload, share | 30 min |
| **TOTAL** | Full production | 5-7 hrs |

---

## Next Steps

1. Review VIDEO_STORYBOARD.md thoroughly
2. Practice with VIDEO_RECORDING_COMMANDS.sh
3. Record a test run (first 60 seconds)
4. Get feedback on test video
5. Record full demo
6. Edit and publish!

**Questions?** Open an issue on GitHub or start a discussion!

Good luck with your video production! 🎬
