# 🔧 TROUBLESHOOTING GUIDE

## Run Scripts

### Option 1: Quick Run (No Backend)
```powershell
.\quick_run.bat
```
- Installs dependencies
- Generates Hive adapters
- Runs app
- **Works offline** (backend optional)

### Option 2: Complete Setup (With Backend)
```powershell
.\complete_setup.bat
```
- Everything in Quick Run
- Installs Supabase CLI
- Deploys backend
- **Requires internet & Supabase account**

---

## Common Errors & Fixes

### Error 1: "flutter: command not found"

**Problem:** Flutter not in PATH

**Fix:**
```powershell
# Find Flutter installation
dir C:\flutter /s /b
dir C:\src\flutter /s /b

# Add to PATH (replace with your path)
$env:PATH += ";C:\flutter\bin"

# Or permanently:
[Environment]::SetEnvironmentVariable("Path", $env:Path + ";C:\flutter\bin", "User")
```

---

### Error 2: "pub get failed"

**Problem:** Package conflicts or network issues

**Fix:**
```powershell
# Clean and retry
flutter clean
flutter pub cache repair
flutter pub get
```

---

### Error 3: "build_runner failed"

**Problem:** Conflicting generated files

**Fix:**
```powershell
# Delete all generated files
del /s lib\*.g.dart
del /s lib\*.freezed.dart

# Regenerate
flutter pub run build_runner build --delete-conflicting-outputs
```

---

### Error 4: "No devices found"

**Problem:** No emulator or physical device connected

**Fix:**
```powershell
# Check available devices
flutter devices

# Start Android emulator
flutter emulators
flutter emulators --launch <emulator_id>

# Or connect physical device with USB debugging enabled
```

---

### Error 5: "Supabase CLI install failed"

**Problem:** Network or permissions issue

**Manual Fix:**
1. Download from: https://github.com/supabase/cli/releases/latest
2. Get `supabase_windows_amd64.zip`
3. Extract `supabase.exe`
4. Move to `C:\Users\<YOU>\bin\`
5. Add to PATH

**Test:**
```powershell
supabase --version
```

---

### Error 6: "Failed to link Supabase project"

**Problem:** Not logged in or wrong credentials

**Fix:**
```powershell
# Login first
supabase login

# Then link
supabase link --project-ref mcwavftuydgkhdsboxpd

# Enter database password when prompted
```

---

### Error 7: "Build failed - compilation error"

**Problem:** Code syntax error

**Fix:**
```powershell
# Check for errors
flutter analyze

# View specific error
flutter build apk --debug
```

**Common causes:**
- Missing import
- Typo in variable name
- Missing semicolon

---

### Error 8: "Hive initialization failed"

**Problem:** Hive adapters not registered

**Fix:**
Check `lib/core/services/hive_service.dart`:
```dart
static Future<void> init() async {
  Hive.registerAdapter(UserModelAdapter());
  Hive.registerAdapter(ExerciseModelAdapter());
  // ... all adapters
}
```

---

### Error 9: "Supabase authentication failed"

**Problem:** Not authenticated or session expired

**Fix in app:**
1. Tap logout in settings
2. Sign up new account
3. Complete onboarding

**Fix in backend:**
```powershell
# Check if logged in
supabase --version
supabase login
```

---

### Error 10: "Edge Function errors in IDE"

**Problem:** TypeScript errors on Deno imports

**This is NORMAL.**

```typescript
// These show red in IDE but work when deployed:
import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
```

**Why:** IDE uses Node TypeScript, functions use Deno TypeScript.

**Fix:** Ignore the errors or install Deno extension for VS Code.

---

## Verification Commands

### Check Flutter Setup
```powershell
flutter doctor -v
```

### Check App Compilation
```powershell
flutter analyze
flutter test
```

### Check Supabase Connection
```powershell
supabase status
supabase projects list
```

### Check Generated Files
```powershell
dir lib\features\models\*.g.dart
```

---

## Reset Everything

### Nuclear Option (Start Fresh)
```powershell
# Clean Flutter
flutter clean
rmdir /s /q build
rmdir /s /q .dart_tool

# Delete generated files
del /s lib\*.g.dart

# Delete Hive data
rmdir /s /q %USERPROFILE%\AppData\Local\raptor_fitt_v2

# Reinstall
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs

# Run
flutter run
```

---

## Development Workflow

### Normal Development
```powershell
# Make code changes
# Hot reload in running app: Press 'r'
# Hot restart: Press 'R'
```

### After Model Changes
```powershell
# Regenerate adapters
flutter pub run build_runner build --delete-conflicting-outputs

# Hot restart
# Press 'R' in running app
```

### After Package Changes
```powershell
# Get new packages
flutter pub get

# Full restart required
# Press 'q' to quit, then flutter run
```

---

## Performance Issues

### Slow Build Times
```powershell
# Use build runner watch mode
flutter pub run build_runner watch

# Leave this running while developing
```

### App Crashes on Startup
```powershell
# Check logs
flutter logs

# Run in debug mode
flutter run --debug

# Check for null safety issues
flutter analyze
```

---

## Backend Issues

### Edge Functions Not Working

**Test locally first:**
```powershell
# Start local Supabase
supabase start

# Test function
curl -X POST http://localhost:54321/functions/v1/parse-workout ^
  -H "Content-Type: application/json" ^
  -d "{\"input\":\"bench 80 3 10\",\"userId\":\"test\"}"
```

### Database Migration Failed

**Check what's deployed:**
```powershell
# Pull current schema
supabase db pull

# Reset and push
supabase db reset
supabase db push
```

---

## Success Indicators

✅ **Setup Complete When:**
- `flutter doctor` shows no critical issues
- `flutter pub get` succeeds
- `*.g.dart` files exist in `lib/features/models/`
- `flutter run` starts the app
- App shows login screen

✅ **Backend Working When:**
- `supabase link` succeeds
- `supabase db push` succeeds
- Edge functions deploy without errors
- App can sign up new users

---

## Getting Help

### Logs to Share
1. `setup_log_*.txt` (from complete_setup.bat)
2. Output of `flutter doctor -v`
3. Output of `flutter analyze`
4. Error screenshot from app

### Where to Check
- Supabase Dashboard: https://supabase.com/dashboard/project/mcwavftuydgkhdsboxpd
- Edge Function Logs: Dashboard → Edge Functions → Logs
- Database Tables: Dashboard → Table Editor

---

## Quick Reference

### Essential Commands
```powershell
# Setup
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs

# Run
flutter run
flutter run --release

# Debug
flutter doctor
flutter analyze
flutter logs

# Clean
flutter clean
rmdir /s /q build

# Supabase
supabase login
supabase link --project-ref mcwavftuydgkhdsboxpd
supabase db push
supabase functions deploy <name>
```

---

## Summary

**Most Common Issue:** Flutter not in PATH  
**Solution:** Add Flutter to system PATH

**Second Most Common:** Hive adapters not generated  
**Solution:** Run build_runner

**Third Most Common:** No device connected  
**Solution:** Start emulator or connect phone

**99% of issues are solved by:**
1. Ensuring Flutter is in PATH
2. Running `flutter pub get`
3. Running build_runner
4. Having a device available

---

**Still stuck? Run this diagnostic:**
```powershell
echo Flutter Doctor:
flutter doctor -v

echo.
echo Devices:
flutter devices

echo.
echo Generated Files:
dir lib\features\models\*.g.dart

echo.
echo Supabase Status:
supabase --version
```

Paste the output when asking for help.
