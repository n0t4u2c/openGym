# Draws the StuFit Android launcher icons and splash screens (orange plate, cream pulse line).
# Rewrites mipmap-*/ic_launcher*.png and every splash.png under the Android res folder, keeping sizes.
# Usage (Windows PowerShell 5.1, no extra tools):
#   scripts\stufit\make-android-art.ps1 -Res frontend\android\app\src\main\res -Out frontend\android\app\src\main\res
# The pulse geometry is the one in frontend/src/components/StuFitLogo.jsx.
param([string]$Res, [string]$Out)
Add-Type -AssemblyName System.Drawing
$orange = [Drawing.ColorTranslator]::FromHtml('#ea580c')
$cream  = [Drawing.ColorTranslator]::FromHtml('#f5f1ea')
$ink    = [Drawing.ColorTranslator]::FromHtml('#0c0e12')
# The pulse line of the StuFit mark, in the 296 unit box of StuFitLogo.jsx
$pulse = @(@(32,154), @(92,154), @(122,76), @(160,224), @(194,116), @(210,154), @(264,154))

function Save-Png([int]$w, [int]$h, [string]$path, [scriptblock]$draw) {
  $b = New-Object Drawing.Bitmap($w, $h, [Drawing.Imaging.PixelFormat]::Format32bppArgb)
  $g = [Drawing.Graphics]::FromImage($b)
  $g.SmoothingMode = 'AntiAlias'; $g.PixelOffsetMode = 'HighQuality'; $g.CompositingQuality = 'HighQuality'
  & $draw $g $w $h
  $g.Dispose()
  New-Item -ItemType Directory -Force (Split-Path $path) | Out-Null
  $b.Save($path, [Drawing.Imaging.ImageFormat]::Png); $b.Dispose()
}
function Draw-Pulse($g, $cx, $cy, $s, $color) {
  $pen = New-Object Drawing.Pen($color, [single](26 * $s))
  $pen.StartCap = 'Round'; $pen.EndCap = 'Round'; $pen.LineJoin = 'Round'
  $pts = $pulse | ForEach-Object { New-Object Drawing.PointF([single]($cx + ($_[0] - 148) * $s), [single]($cy + ($_[1] - 148) * $s)) }
  $g.DrawLines($pen, [Drawing.PointF[]]$pts); $pen.Dispose()
}

# Launcher: adaptive layers (108 dp canvas) and the legacy icons for Android 7.x (48 dp)
$dens = [ordered]@{ ldpi = @(81, 36); mdpi = @(108, 48); hdpi = @(162, 72); xhdpi = @(216, 96); xxhdpi = @(324, 144); xxxhdpi = @(432, 192) }
foreach ($d in $dens.Keys) {
  $n = $dens[$d][0]; $l = $dens[$d][1]; $dir = "$Out\mipmap-$d"
  Save-Png $n $n "$dir\ic_launcher_background.png" { param($g, $w, $h) $g.Clear($orange) }
  Save-Png $n $n "$dir\ic_launcher_foreground.png" { param($g, $w, $h) Draw-Pulse $g ($w / 2) ($h / 2) (1.05 * $w / 432) $cream }
  Save-Png $l $l "$dir\ic_launcher.png" { param($g, $w, $h)
    $r = 0.4 * $w; $p = New-Object Drawing.Drawing2D.GraphicsPath
    $p.AddArc(0, 0, $r, $r, 180, 90); $p.AddArc($w - $r, 0, $r, $r, 270, 90); $p.AddArc($w - $r, $h - $r, $r, $r, 0, 90); $p.AddArc(0, $h - $r, $r, $r, 90, 90); $p.CloseFigure()
    $g.FillPath((New-Object Drawing.SolidBrush($orange)), $p)
    Draw-Pulse $g ($w / 2) ($h / 2) (0.0024 * $w) $cream }
  Save-Png $l $l "$dir\ic_launcher_round.png" { param($g, $w, $h)
    $g.FillEllipse((New-Object Drawing.SolidBrush($orange)), 0, 0, $w, $h)
    Draw-Pulse $g ($w / 2) ($h / 2) (0.0024 * $w) $cream }
}

# Splash: every existing splash.png keeps its size, now the orange mark on the dark ground
Get-ChildItem $Res -Recurse -Filter splash.png | ForEach-Object {
  $img = [Drawing.Image]::FromFile($_.FullName); $w = $img.Width; $h = $img.Height; $img.Dispose()
  $rel = $_.FullName.Substring($Res.Length).TrimStart('\')
  Save-Png $w $h "$Out\$rel" { param($g, $w, $h)
    $g.Clear($ink)
    $m = 0.26 * [Math]::Min($w, $h)
    $g.FillEllipse((New-Object Drawing.SolidBrush($orange)), ($w - $m) / 2, ($h - $m) / 2, $m, $m)
    Draw-Pulse $g ($w / 2) ($h / 2) ($m / 296) $cream }
}
"done"

