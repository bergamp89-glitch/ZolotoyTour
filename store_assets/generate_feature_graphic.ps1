Add-Type -AssemblyName System.Drawing

$width = 1024
$height = 500
$bmp = [System.Drawing.Bitmap]::new($width, $height)
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::ClearTypeGridFit
$g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic

# Background gradient
$p1 = [System.Drawing.Point]::new(0, 0)
$p2 = [System.Drawing.Point]::new($width, $height)
$c1 = [System.Drawing.ColorTranslator]::FromHtml('#121212')
$c2 = [System.Drawing.ColorTranslator]::FromHtml('#202020')
$bgBrush = [System.Drawing.Drawing2D.LinearGradientBrush]::new($p1, $p2, $c1, $c2)
$g.FillRectangle($bgBrush, 0, 0, $width, $height)
$bgBrush.Dispose()

# Subtle gold glow ellipse in center
$path = [System.Drawing.Drawing2D.GraphicsPath]::new()
$path.AddEllipse(212, -70, 600, 640)
$pathBrush = [System.Drawing.Drawing2D.PathGradientBrush]::new($path)
$pathBrush.CenterColor = [System.Drawing.Color]::FromArgb(50, 210, 162, 88)
$pathBrush.SurroundColors = @([System.Drawing.Color]::FromArgb(0, 18, 18, 18))
$g.FillPath($pathBrush, $path)
$pathBrush.Dispose()
$path.Dispose()

# Subtle gold border
$borderPen = [System.Drawing.Pen]::new([System.Drawing.ColorTranslator]::FromHtml('#D2A258'), [float]2)
$g.DrawRectangle($borderPen, 1, 1, ($width - 2), ($height - 2))
$borderPen.Dispose()

# Draw logo
$logoPath = Join-Path (Get-Location) 'assets\images\logo.png'
if (Test-Path $logoPath) {
    $logo = [System.Drawing.Image]::FromFile($logoPath)
    $logoH = 190
    $logoW = [int]($logo.Width * ($logoH / $logo.Height))
    $logoX = [int](($width - $logoW) / 2)
    $logoY = 60
    $g.DrawImage($logo, $logoX, $logoY, $logoW, $logoH)
    $logo.Dispose()
}

# Typography
$goldBrush = [System.Drawing.SolidBrush]::new([System.Drawing.ColorTranslator]::FromHtml('#D2A258'))
$whiteBrush = [System.Drawing.SolidBrush]::new([System.Drawing.ColorTranslator]::FromHtml('#FFFFFF'))
$mutedBrush = [System.Drawing.SolidBrush]::new([System.Drawing.ColorTranslator]::FromHtml('#B0B0B0'))

$titleFont = [System.Drawing.Font]::new('Segoe UI', [float]30, [System.Drawing.FontStyle]::Bold)
$subFont = [System.Drawing.Font]::new('Segoe UI', [float]15, [System.Drawing.FontStyle]::Regular)
$tagFont = [System.Drawing.Font]::new('Segoe UI', [float]11, [System.Drawing.FontStyle]::Bold)

$sf = [System.Drawing.StringFormat]::new()
$sf.Alignment = [System.Drawing.StringAlignment]::Center
$sf.LineAlignment = [System.Drawing.StringAlignment]::Center

$g.DrawString('ZOLOTOY TOUR', $titleFont, $goldBrush, [float]($width / 2), 315.0, $sf)
$g.DrawString('Dunyo boylab unutilmas sayohatlar va qaynoq turlar', $subFont, $whiteBrush, [float]($width / 2), 375.0, $sf)
$g.DrawString('OFFICIAL MOBILE APPLICATION', $tagFont, $mutedBrush, [float]($width / 2), 425.0, $sf)

$outPath = Join-Path (Get-Location) 'store_assets\feature_graphic_1024x500.png'
$bmp.Save($outPath, [System.Drawing.Imaging.ImageFormat]::Png)

$titleFont.Dispose(); $subFont.Dispose(); $tagFont.Dispose(); $sf.Dispose()
$goldBrush.Dispose(); $whiteBrush.Dispose(); $mutedBrush.Dispose()
$g.Dispose(); $bmp.Dispose()
Write-Host "Feature graphic successfully generated at: $outPath"
