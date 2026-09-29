Add-Type -AssemblyName System.Drawing

$width = 1080
$height = 2400
$storeDir = Join-Path (Get-Location) 'store_assets'

$screens = @(
    @{
        Name = 'screenshot_1_home.png'
        Title = 'ZOLOTOY TOUR'
        Subtitle = 'Dunyo boylab unutilmas sayohatlar va qaynoq turlar'
        Tag = 'BOSH SAHIFA'
        Feature1 = 'Turkiya, Dubay, Misr, Tailand va Yevropa'
        Feature2 = 'Ishonchli va tajribali sayohat hamkori'
        Accent = '#D2A258'
    },
    @{
        Name = 'screenshot_2_tours.png'
        Title = 'QULAY TUR TANLASH'
        Subtitle = 'Istalgan davlat va mehmonxonani bir zumda toping'
        Tag = 'TUR QIDIRUVI'
        Feature1 = 'Real vaqtdagi yangilangan narxlar'
        Feature2 = 'Yulduzlar darajasi va ovqatlanish turlari'
        Accent = '#D2A258'
    },
    @{
        Name = 'screenshot_3_hot_tours.png'
        Title = 'QAYNOQ TURLAR'
        Subtitle = 'Eng arzon narxlardagi chegirilmali sayohatlar'
        Tag = 'CHEGIRMALAR'
        Feature1 = 'Har kuni yangilanadigan maxsus takliflar'
        Feature2 = 'Tezkor bron qilish va tolov imkoniyati'
        Accent = '#E5A93C'
    },
    @{
        Name = 'screenshot_4_services.png'
        Title = 'BARCHA XIZMATLAR'
        Subtitle = 'Sayohat uchun barcha zarur xizmatlar bir joyda'
        Tag = 'XIZMATLAR'
        Feature1 = 'Viza olishda professional yordam va konsultatsiya'
        Feature2 = 'Arzon aviachiptalar va sayohat sugurtasi'
        Accent = '#D2A258'
    },
    @{
        Name = 'screenshot_5_contacts.png'
        Title = '24/7 ALOQA VA MANZIL'
        Subtitle = 'Professional mutaxassislar sizga yordamga tayyor'
        Tag = 'MIJOZLAR XIZMATI'
        Feature1 = 'Namangan shahar, Hamroh kochasi 5-uy'
        Feature2 = 'Telefon: +998 77 043 44 44 | Telegram: @zolotoy_tour'
        Accent = '#4CAF50'
    }
)

$logoPath = Join-Path (Get-Location) 'assets\images\logo.png'
$logo = $null
if (Test-Path $logoPath) {
    $logo = [System.Drawing.Image]::FromFile($logoPath)
}

foreach ($screen in $screens) {
    $bmp = [System.Drawing.Bitmap]::new($width, $height)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::ClearTypeGridFit
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic

    # Top gradient background
    $p1 = [System.Drawing.Point]::new(0, 0)
    $p2 = [System.Drawing.Point]::new($width, $height)
    $c1 = [System.Drawing.ColorTranslator]::FromHtml('#161616')
    $c2 = [System.Drawing.ColorTranslator]::FromHtml('#252525')
    $bgBrush = [System.Drawing.Drawing2D.LinearGradientBrush]::new($p1, $p2, $c1, $c2)
    $g.FillRectangle($bgBrush, 0, 0, $width, $height)
    $bgBrush.Dispose()

    # Glow accent
    $glowPath = [System.Drawing.Drawing2D.GraphicsPath]::new()
    $glowPath.AddEllipse(100, 100, 880, 700)
    $glowBrush = [System.Drawing.Drawing2D.PathGradientBrush]::new($glowPath)
    $glowBrush.CenterColor = [System.Drawing.Color]::FromArgb(40, 210, 162, 88)
    $glowBrush.SurroundColors = @([System.Drawing.Color]::FromArgb(0, 20, 20, 20))
    $g.FillPath($glowBrush, $glowPath)
    $glowBrush.Dispose()
    $glowPath.Dispose()

    # Top Badge / Tag
    $tagBrush = [System.Drawing.SolidBrush]::new([System.Drawing.ColorTranslator]::FromHtml('#D2A258'))
    $tagBgBrush = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(50, 210, 162, 88))
    $tagPen = [System.Drawing.Pen]::new([System.Drawing.ColorTranslator]::FromHtml('#D2A258'), [float]2)
    
    $tagFont = [System.Drawing.Font]::new('Segoe UI', [float]20, [System.Drawing.FontStyle]::Bold)
    $titleFont = [System.Drawing.Font]::new('Segoe UI', [float]48, [System.Drawing.FontStyle]::Bold)
    $subFont = [System.Drawing.Font]::new('Segoe UI', [float]26, [System.Drawing.FontStyle]::Regular)
    $itemFont = [System.Drawing.Font]::new('Segoe UI', [float]24, [System.Drawing.FontStyle]::Bold)

    $sf = [System.Drawing.StringFormat]::new()
    $sf.Alignment = [System.Drawing.StringAlignment]::Center
    $sf.LineAlignment = [System.Drawing.StringAlignment]::Center

    # Draw tag capsule
    $tagRect = [System.Drawing.RectangleF]::new(360, 110, 360, 64)
    $g.FillRectangle($tagBgBrush, 360, 110, 360, 64)
    $g.DrawRectangle($tagPen, 360, 110, 360, 64)
    $g.DrawString($screen.Tag, $tagFont, $tagBrush, 540, 142, $sf)

    # Draw Title & Subtitle
    $whiteBrush = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::White)
    $mutedBrush = [System.Drawing.SolidBrush]::new([System.Drawing.ColorTranslator]::FromHtml('#CCCCCC'))

    $g.DrawString($screen.Title, $titleFont, $tagBrush, 540, 240, $sf)
    $g.DrawString($screen.Subtitle, $subFont, $mutedBrush, 540, 320, $sf)

    # Phone Frame representation
    $phoneX = 90
    $phoneY = 440
    $phoneW = 900
    $phoneH = 1860

    $phoneBgBrush = [System.Drawing.SolidBrush]::new([System.Drawing.ColorTranslator]::FromHtml('#1C1C1C'))
    $phoneBorderPen = [System.Drawing.Pen]::new([System.Drawing.ColorTranslator]::FromHtml('#383838'), [float]8)
    $goldInnerPen = [System.Drawing.Pen]::new([System.Drawing.ColorTranslator]::FromHtml('#D2A258'), [float]3)

    $g.FillRectangle($phoneBgBrush, $phoneX, $phoneY, $phoneW, $phoneH)
    $g.DrawRectangle($phoneBorderPen, $phoneX, $phoneY, $phoneW, $phoneH)
    $g.DrawRectangle($goldInnerPen, ($phoneX + 16), ($phoneY + 16), ($phoneW - 32), ($phoneH - 32))

    # Top phone speaker / camera notch
    $notchBrush = [System.Drawing.SolidBrush]::new([System.Drawing.ColorTranslator]::FromHtml('#0A0A0A'))
    $g.FillRectangle($notchBrush, 450, ($phoneY + 26), 180, 22)
    $notchBrush.Dispose()

    # Phone Screen Header inside Mockup
    if ($null -ne $logo) {
        $lH = 160
        $lW = [int]($logo.Width * ($lH / $logo.Height))
        $lX = [int](($width - $lW) / 2)
        $lY = $phoneY + 100
        $g.DrawImage($logo, $lX, $lY, $lW, $lH)
    }

    # Internal Card 1 inside Mockup
    $card1Brush = [System.Drawing.SolidBrush]::new([System.Drawing.ColorTranslator]::FromHtml('#2A2A2A'))
    $card1Pen = [System.Drawing.Pen]::new([System.Drawing.ColorTranslator]::FromHtml('#D2A258'), [float]2)
    $g.FillRectangle($card1Brush, 160, ($phoneY + 360), 760, 240)
    $g.DrawRectangle($card1Pen, 160, ($phoneY + 360), 760, 240)
    $g.DrawString($screen.Feature1, $itemFont, $whiteBrush, 540, ($phoneY + 480), $sf)

    # Internal Card 2 inside Mockup
    $card2Brush = [System.Drawing.SolidBrush]::new([System.Drawing.ColorTranslator]::FromHtml('#242424'))
    $card2Pen = [System.Drawing.Pen]::new([System.Drawing.ColorTranslator]::FromHtml('#444444'), [float]2)
    $g.FillRectangle($card2Brush, 160, ($phoneY + 650), 760, 240)
    $g.DrawRectangle($card2Pen, 160, ($phoneY + 650), 760, 240)
    $g.DrawString($screen.Feature2, $itemFont, $tagBrush, 540, ($phoneY + 770), $sf)

    # Internal Card 3 (Action Button)
    $btnBrush = [System.Drawing.SolidBrush]::new([System.Drawing.ColorTranslator]::FromHtml('#D2A258'))
    $btnDarkText = [System.Drawing.SolidBrush]::new([System.Drawing.ColorTranslator]::FromHtml('#181818'))
    $btnFont = [System.Drawing.Font]::new('Segoe UI', [float]26, [System.Drawing.FontStyle]::Bold)
    $g.FillRectangle($btnBrush, 240, ($phoneY + 980), 600, 110)
    $g.DrawString('ILOVANI YUKLAB OLING', $btnFont, $btnDarkText, 540, ($phoneY + 1035), $sf)

    # Bottom Nav Bar simulation inside Mockup
    $navBrush = [System.Drawing.SolidBrush]::new([System.Drawing.ColorTranslator]::FromHtml('#141414'))
    $navPen = [System.Drawing.Pen]::new([System.Drawing.ColorTranslator]::FromHtml('#333333'), [float]2)
    $g.FillRectangle($navBrush, ($phoneX + 16), ($phoneY + $phoneH - 160), ($phoneW - 32), 140)
    $g.DrawLine($navPen, ($phoneX + 16), ($phoneY + $phoneH - 160), ($phoneX + $phoneW - 16), ($phoneY + $phoneH - 160))

    $navFont = [System.Drawing.Font]::new('Segoe UI', [float]18, [System.Drawing.FontStyle]::Bold)
    $g.DrawString('Bosh sahifa  |  Turlar  |  Qaynoq  |  Xizmatlar  |  Aloqa', $navFont, $tagBrush, 540, ($phoneY + $phoneH - 90), $sf)

    # Save screenshot
    $outPath = Join-Path $storeDir $screen.Name
    $bmp.Save($outPath, [System.Drawing.Imaging.ImageFormat]::Png)

    # Cleanup
    $tagFont.Dispose(); $titleFont.Dispose(); $subFont.Dispose(); $itemFont.Dispose()
    $btnFont.Dispose(); $navFont.Dispose(); $sf.Dispose()
    $tagBrush.Dispose(); $tagBgBrush.Dispose(); $tagPen.Dispose(); $whiteBrush.Dispose()
    $mutedBrush.Dispose(); $phoneBgBrush.Dispose(); $phoneBorderPen.Dispose(); $goldInnerPen.Dispose()
    $card1Brush.Dispose(); $card1Pen.Dispose(); $card2Brush.Dispose(); $card2Pen.Dispose()
    $btnBrush.Dispose(); $btnDarkText.Dispose(); $navBrush.Dispose(); $navPen.Dispose()
    $g.Dispose(); $bmp.Dispose()
    Write-Host "Generated: $($screen.Name)"
}

if ($null -ne $logo) {
    $logo.Dispose()
}
Write-Host "All screenshots generated successfully!"
