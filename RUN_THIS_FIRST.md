# ▶️ RUN THIS FIRST

## Fastest Path to Running App

### Step 1: Run Quick Setup
```powershell
.\quick_run.bat
```

**What this does:**
1. Installs Flutter packages
2. Generates Hive adapters
3. Runs the app

**Time:** 2-5 minutes

---

## If You Get Errors

### Error: "flutter not found"
```powershell
# Check if Flutter is installed
where flutter

# If not found, download from:
# https://flutter.dev/docs/get-started/install/windows

# After install, add to PATH:
# C:\flutter\bin (or wherever you installed it)
```

### Error: "No devices found"
```powershell
# Connect Android phone with USB debugging
# OR start Android emulator
# OR install Android Studio
```

### Error: "build_runner failed"
```powershell
# Clean and retry
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

---

## What You Can Do Without Backend

✅ **Works Offline:**
- View app UI
- Create user profile (local only)
- Log workouts (stored in Hive)
- Track nutrition
- Track sleep
- View analytics

❌ **Needs Backend:**
- AI workout parsing (uses local regex fallback)
- AI insights (shows placeholder)
- Cloud sync
- Multi-device sync
- Social features

**The app is offline-first, so everything works locally!**

---

## Deploy Backend Later (Optional)

### When you're ready:
```powershell
.\complete_setup.bat
```

**Requirements:**
- Supabase account
- Internet connection
- 10-15 minutes

**What this does:**
- Installs Supabase CLI
- Deploys database
- Deploys Edge Functions
- Enables AI features

---

## Quick Test After Running

1. **App opens** → Login screen visible ✅
2. **Tap "Sign Up"** → Signup form appears ✅
3. **Fill form** → Validation works ✅
4. **Sign up** → Redirects to onboarding ✅
5. **Complete profile** → Redirects to dashboard ✅
6. **Tap Quick Log** → Can input workout ✅
7. **Type "bench 80 3 10"** → Parses correctly ✅
8. **Save workout** → Success message ✅

---

## Files Overview

### Run Scripts
- `quick_run.bat` - **Start here** (no backend needed)
- `complete_setup.bat` - Full setup with backend
- `deploy_supabase.bat` - Backend deployment only

### Documentation
- `RUN_THIS_FIRST.md` - **This file**
- `TROUBLESHOOTING.md` - Error fixes
- `ALL_FEATURES_IMPLEMENTED.md` - What was built
- `HONEST_FINAL_STATUS.md` - Production readiness
- `FINAL_DEPLOYMENT_GUIDE.md` - Full deployment guide

### Important Code
- `lib/main.dart` - App entry point
- `lib/features/auth/` - Login/signup screens
- `lib/core/services/` - All services
- `supabase/functions/` - Edge Functions
- `supabase/migrations/` - Database schema

---

## Expected First Run

```
[1/4] Installing dependencies...
Resolving dependencies... (30-60 seconds)
Got dependencies!

[2/4] Generating Hive adapters...
[INFO] Generating build script completed (5 seconds)
[INFO] Creating build script snapshot (10 seconds)
[INFO] Building new asset graph completed (15 seconds)
[INFO] Succeeded after 30 seconds

[3/4] Checking for devices...
2 connected devices:
- Windows (desktop) • windows
- Chrome (web) • chrome

[4/4] Running app...
Launching lib\main.dart on Windows in debug mode...
Building Windows application...
Running Gradle task 'assembleDebug'...

✓ Built build\windows\runner\Debug\raptor_fitt.exe

App running on Windows!
```

---

## Troubleshooting Decision Tree

```
Can't run script?
├─ Flutter not found → Install Flutter
├─ Permission denied → Run as Administrator
└─ Syntax error → Use PowerShell (not CMD)

Script runs but fails?
├─ pub get fails → Check internet, run flutter clean
├─ build_runner fails → Delete .g.dart files, retry
└─ No device → Connect phone or start emulator

App runs but crashes?
├─ Hive error → Check adapters were generated
├─ Null error → Check auth state
└─ Network error → Backend not deployed (OK, use offline)

Backend deployment fails?
├─ Supabase login fails → Check browser opened
├─ Link fails → Check project ref, enter password
└─ Functions fail → Check logs, redeploy
```

---

## What Happens When You Run

### Local App (No Backend)
```
1. App starts
2. Checks Supabase auth → Not authenticated
3. Shows login screen
4. You sign up → Creates Supabase auth user
5. You complete onboarding → Saves to Hive
6. Dashboard loads → Shows local data
7. Log workout → Saves to Hive
8. Sync queued → Will sync when backend deployed
```

### With Backend
```
1-5. Same as above
6. Dashboard loads → Fetches AI insight from Groq
7. Log workout → Parses with Groq AI
8. Sync → Immediately syncs to Supabase
9. Logout/login → Data persists in cloud
```

---

## Success Checklist

After running `quick_run.bat`:

- [ ] Script completed without errors
- [ ] App window opened
- [ ] Login screen visible
- [ ] Can click "Sign Up"
- [ ] Form accepts input
- [ ] Sign up creates account
- [ ] Onboarding form loads
- [ ] Can complete profile
- [ ] Dashboard appears
- [ ] Can navigate screens
- [ ] Quick Log accepts input

**If all checked: SUCCESS! ✅**

---

## Next Steps

### Immediate
1. Run `quick_run.bat`
2. Test signup flow
3. Log a workout
4. Explore screens

### Soon
1. Run `complete_setup.bat`
2. Deploy backend
3. Test AI features
4. Test cloud sync

### Optional
1. Read `TROUBLESHOOTING.md`
2. Read `ALL_FEATURES_IMPLEMENTED.md`
3. Check Supabase dashboard
4. Review Edge Functions

---

## One-Line Summary

**To run app:** `.\quick_run.bat` → Wait 2-5 min → App opens → Sign up → Use app ✅

**To deploy backend:** `.\complete_setup.bat` → Login to Supabase → Enter password → Done ✅

---

## Still Confused?

Just run this:
```powershell
.\quick_run.bat
```

If it fails, paste the error here:
- [ ] Full error message
- [ ] Output of `flutter doctor -v`
- [ ] Screenshot if relevant

I'll fix it.

---

**BOTTOM LINE:**

1. Run `quick_run.bat`
2. If error, check `TROUBLESHOOTING.md`
3. If still stuck, paste error

**The app works offline by default. Backend is optional bonus.**

🚀 **GO RUN IT NOW** 🚀
