\# R in VS Code Setup Guide for Windows

## Prerequisites

- R installed at `C:\Program Files\R\R-4.4.3` (or similar version)
- VS Code with R Extension (by REditorSupport) installed
- Windows operating system

## Step 1: Configure R in VS Code

## Step 1: Configure R in VS Code

1. **Create `.Rprofile` file to fix library path issues:**
   - Open File Explorer and navigate to: `C:\Users\YOUR_USERNAME\Documents`
   - Create a new file named `.Rprofile` (note the dot at the start)
   - Open it in Notepad and paste this content:

```r
# Set library path consistently
.libPaths(c("C:/Users/YOUR_USERNAME/AppData/Local/R/win-library/4.4",
            "C:/Program Files/R/R-4.4.3/library"))

# Ensure packages install to user library by default
Sys.setenv(R_LIBS_USER = "C:/Users/YOUR_USERNAME/AppData/Local/R/win-library/4.4")

# Create user library if it doesn't exist
if (!dir.exists(Sys.getenv("R_LIBS_USER"))) {
  dir.create(Sys.getenv("R_LIBS_USER"), recursive = TRUE)
}

# Print confirmation on startup
cat("\nR library paths configured:\n")
cat(paste(.libPaths(), collapse = "\n"), "\n\n")
```

   - **Replace `YOUR_USERNAME`** with your actual Windows username
   - **Replace `4.4`** with your R version (e.g., if you have R-4.3.x, use `4.3`)
   - Save the file

2. **Create workspace settings file:**
   - In your project folder, create a folder named `.vscode`
   - Inside `.vscode`, create a file named `settings.json`
   - Add this content:

```json
{
  "r.rterm.windows": "C:\\Program Files\\R\\R-4.4.3\\bin\\x64\\R.exe",
  "r.rpath.windows": "C:\\Program Files\\R\\R-4.4.3\\bin\\x64\\R.exe",
  "r.bracketedPaste": true,
  "r.sessionWatcher": true,
  "terminal.integrated.env.windows": {
    "R_LIBS_USER": "C:\\Users\\YOUR_USERNAME\\AppData\\Local\\R\\win-library\\4.4"
  }
}
```

   - **Important:** 
     - Change `R-4.4.3` to match YOUR R version if different
     - Change `YOUR_USERNAME` to your actual Windows username
     - Change `4.4` to match your R version (4.4.x → 4.4, 4.3.x → 4.3)

3. **Restart VS Code:**
   - Press `Ctrl+Shift+P`
   - Type: "Developer: Reload Window"
   - Press Enter

## Step 2: Open R Terminal

**To open an R Interactive terminal in VS Code:**
- Press `Ctrl+Shift+P`
- Type: "R: Create R Terminal"
- Press Enter

You should see a message showing your library paths are configured correctly.

## Step 3: Install and Load R Packages

## Step 3: Install and Load R Packages

### Method A: Using R Terminal (Recommended)

1. Open R terminal (see Step 2)

2. Install packages:
```r
install.packages("FielDHub", repos = "https://cloud.r-project.org")
```

3. Load the package:
```r
library(FielDHub)
```

**Important:** Package names are case-sensitive! Use `FielDHub`, not `FieldHub`.

### Method B: Using R Extension GUI

1. Press `Ctrl+Shift+P`
2. Type: "R: Install R Package"
3. Enter package name exactly: `FielDHub`
4. Wait for installation to complete
5. Close the R terminal and open a new one
6. Load the package: `library(FielDHub)`

## Step 4: Verify Setup

## Step 4: Verify Setup

1. **Open an R terminal:**
   - Press `Ctrl+Shift+P`
   - Type: "R: Create R Terminal"
   - Press Enter

2. **Check library paths (should show configured paths):**
```r
.libPaths()
```
Expected output:
```
[1] "C:/Users/YOUR_USERNAME/AppData/Local/R/win-library/4.4"
[2] "C:/Program Files/R/R-4.4.3/library"
```

3. **Test package loading:**
```r
library(FielDHub)
```
Should load without errors.

## Troubleshooting

### Problem: "there is no package called 'X'" after installing via GUI

**Root Cause:** The R extension GUI sometimes installs to a different library location than R terminals use.

**Solution:**
1. Create the `.Rprofile` file as described in Step 1.1 (fixes library path consistency)
2. Reload VS Code: `Ctrl+Shift+P` → "Developer: Reload Window"
3. Open new R terminal and reinstall:
```r
install.packages("FielDHub", repos = "https://cloud.r-project.org")
```
4. Test: `library(FielDHub)`

### Problem: Package name errors

**Solution:** R package names are case-sensitive. Common mistakes:
- ❌ `library(FieldHub)` 
- ✅ `library(FielDHub)`

Check the exact package name on CRAN or the documentation.

### Problem: Library paths not showing configured paths

**Solution:**
1. Verify `.Rprofile` exists at: `C:\Users\YOUR_USERNAME\Documents\.Rprofile`
2. Check that `YOUR_USERNAME` was replaced with your actual username
3. Check that R version numbers match your installation
4. Close all R terminals and reload VS Code
5. Open new R terminal and check `.libPaths()` again

### Problem: R terminal not opening

**Solution:**
1. Verify R is installed. Open PowerShell and run:
```powershell
& "C:\Program Files\R\R-4.4.3\bin\x64\R.exe" --version
```
2. If path is different, update `.vscode\settings.json` with correct R path
3. Reload VS Code

### Problem: Packages installed but not loading in new terminal

**Solution:**
1. Check that `.Rprofile` is properly configured (Step 1.1)
2. Verify the library path in `.Rprofile` matches where packages are installed:
```r
installed.packages()[,"LibPath"]
```
3. If packages are in a different location, update `.Rprofile` paths to match
4. Restart all R sessions

## Best Practices

1. ✅ **Create `.Rprofile`** to ensure consistent library paths across all R sessions
2. ✅ **Install packages in R terminal** for reliability
3. ✅ **Always close and reopen R terminal** after installing packages via GUI
4. ✅ **Use exact package names** (case-sensitive: `FielDHub` not `FieldHub`)
5. ✅ **Check `.libPaths()`** if packages aren't loading
6. ❌ **Don't mix different R installations** (32-bit vs 64-bit)

## Common Packages to Install

```r
# Install commonly used packages
install.packages(c("ggplot2", "dplyr", "tidyr", "readr", "knitr", "rmarkdown", "FielDHub"), 
                 repos = "https://cloud.r-project.org")
```

## Quick Reference

| Task | Command |
|------|---------|
| Open R Terminal | `Ctrl+Shift+P` → "R: Create R Terminal" |
| Install Package (terminal) | `install.packages("package_name", repos = "https://cloud.r-project.org")` |
| Install Package (GUI) | `Ctrl+Shift+P` → "R: Install R Package" |
| Load Package | `library(package_name)` |
| Check R Version | `R.version.string` |
| Check Library Paths | `.libPaths()` |
| List Installed Packages | `rownames(installed.packages())` |
| Find Package Location | `find.package("package_name")` |
| Reload VS Code | `Ctrl+Shift+P` → "Developer: Reload Window" |

## Summary

The most common issue is **library path inconsistency** between GUI installations and R terminals. The `.Rprofile` file (Step 1.1) solves this by forcing all R sessions to use the same library locations. Always verify with `.libPaths()` and remember package names are case-sensitive.

---

**Questions?** Contact your instructor or refer to the R extension documentation:
[https://github.com/REditorSupport/vscode-R](https://github.com/REditorSupport/vscode-R)
