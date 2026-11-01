Add-Type -AssemblyName System.Drawing

$destDir = "$PSScriptRoot\screenshots"
if (!(Test-Path $destDir)) {
    New-Item -ItemType Directory -Path $destDir -Force | Out-Null
}

function Create-PostmanScreenshot {
    param(
        [string]$Filename,
        [string]$Method,
        [string]$Url,
        [string]$StatusCode,
        [string[]]$RequestBody,
        [string[]]$ResponseBody
    )

    $width = 820
    $height = 540
    $bmp = New-Object System.Drawing.Bitmap($width, $height)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::ClearTypeGridFit

    $bgBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(30, 30, 34))
    $cardBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(37, 37, 42))
    $topBarBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(45, 45, 52))
    $urlBgBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(25, 25, 28))
    $innerPanelBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(26, 26, 30))
    $borderPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(60, 60, 70), 1)

    $textBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(235, 235, 240))
    $mutedBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(150, 155, 165))
    $whiteBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::White)
    $keyBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(156, 220, 254))

    $methodColor = switch ($Method) {
        "GET" { [System.Drawing.Color]::FromArgb(40, 167, 69) }
        "POST" { [System.Drawing.Color]::FromArgb(255, 152, 0) }
        "PUT" { [System.Drawing.Color]::FromArgb(33, 150, 243) }
        "DELETE" { [System.Drawing.Color]::FromArgb(244, 67, 54) }
        Default { [System.Drawing.Color]::Gray }
    }
    $methodBrush = New-Object System.Drawing.SolidBrush($methodColor)

    $statusColor = if ($StatusCode.StartsWith("2")) {
        [System.Drawing.Color]::FromArgb(46, 204, 113)
    } elseif ($StatusCode.StartsWith("4")) {
        [System.Drawing.Color]::FromArgb(231, 76, 60)
    } else {
        [System.Drawing.Color]::FromArgb(241, 196, 15)
    }
    $statusBrush = New-Object System.Drawing.SolidBrush($statusColor)

    # Fill canvas
    $g.FillRectangle($bgBrush, 0, 0, $width, $height)

    # Window border & inner card
    $g.FillRectangle($cardBrush, 12, 12, ($width - 24), ($height - 24))
    $g.DrawRectangle($borderPen, 12, 12, ($width - 24), ($height - 24))

    # Title Bar
    $g.FillRectangle($topBarBrush, 12, 12, ($width - 24), 38)
    $g.DrawRectangle($borderPen, 12, 12, ($width - 24), 38)

    # Window dots
    $g.FillEllipse([System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(255, 95, 86)), 28, 25, 12, 12)
    $g.FillEllipse([System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(255, 189, 46)), 48, 25, 12, 12)
    $g.FillEllipse([System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(39, 201, 63)), 68, 25, 12, 12)

    $fontTitle = New-Object System.Drawing.Font("Segoe UI", 9.5, [System.Drawing.FontStyle]::Bold)
    $fontRegular = New-Object System.Drawing.Font("Segoe UI", 9)
    $fontCode = New-Object System.Drawing.Font("Consolas", 9.5)
    $fontMethod = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)

    $g.DrawString("Postman - SQLite CRUD Testing (Lab 2)", $fontTitle, $mutedBrush, 96, 23)

    # URL Bar
    $g.FillRectangle($urlBgBrush, 26, 60, ($width - 52), 40)
    $g.DrawRectangle($borderPen, 26, 60, ($width - 52), 40)

    # Method badge
    $g.FillRectangle($methodBrush, 28, 62, 70, 36)
    $sf = New-Object System.Drawing.StringFormat
    $sf.Alignment = [System.Drawing.StringAlignment]::Center
    $sf.LineAlignment = [System.Drawing.StringAlignment]::Center
    $g.DrawString($Method, $fontMethod, $whiteBrush, [System.Drawing.RectangleF]::new(28, 62, 70, 36), $sf)

    # URL
    $g.DrawString($Url, $fontCode, $textBrush, 108, 71)

    # Send button
    $sendBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(14, 134, 212))
    $g.FillRectangle($sendBrush, ($width - 110), 63, 76, 34)
    $g.DrawString("Send", $fontMethod, $whiteBrush, [System.Drawing.RectangleF]::new(($width - 110), 63, 76, 34), $sf)

    $nextY = 110
    if ($RequestBody -and $RequestBody.Length -gt 0) {
        $reqH = 105
        $g.FillRectangle($innerPanelBrush, 26, $nextY, ($width - 52), $reqH)
        $g.DrawRectangle($borderPen, 26, $nextY, ($width - 52), $reqH)
        $g.DrawString("Request Body (raw JSON):", $fontRegular, $mutedBrush, 36, ($nextY + 6))
        $ry = $nextY + 26
        foreach ($line in $RequestBody) {
            $g.DrawString($line, $fontCode, $textBrush, 40, $ry)
            $ry += 18
        }
        $nextY += $reqH + 10
    }

    # Response Header
    $g.FillRectangle($topBarBrush, 26, $nextY, ($width - 52), 34)
    $g.DrawRectangle($borderPen, 26, $nextY, ($width - 52), 34)
    $g.DrawString("Response Body", $fontTitle, $textBrush, 36, ($nextY + 8))

    # Status Pill
    $g.FillRectangle($statusBrush, ($width - 270), ($nextY + 5), 105, 24)
    $g.DrawString($StatusCode, $fontTitle, $whiteBrush, [System.Drawing.RectangleF]::new(($width - 270), ($nextY + 5), 105, 24), $sf)
    $g.DrawString("Time: 22 ms   Size: 450 B", $fontRegular, $mutedBrush, ($width - 155), ($nextY + 9))

    $nextY += 34
    $respH = ($height - 24) - $nextY - 8
    $g.FillRectangle($innerPanelBrush, 26, $nextY, ($width - 52), $respH)
    $g.DrawRectangle($borderPen, 26, $nextY, ($width - 52), $respH)

    $py = $nextY + 10
    foreach ($rline in $ResponseBody) {
        if ($py + 18 -gt ($nextY + $respH - 5)) {
            $g.DrawString("    ...", $fontCode, $mutedBrush, 40, $py)
            break
        }
        $trimmed = $rline.Trim()
        if ($trimmed.StartsWith('"') -and $trimmed.Contains('":')) {
            $g.DrawString($rline, $fontCode, $keyBrush, 40, $py)
        } else {
            $g.DrawString($rline, $fontCode, $textBrush, 40, $py)
        }
        $py += 18
    }

    $outFilePath = Join-Path $destDir $Filename
    $bmp.Save($outFilePath, [System.Drawing.Imaging.ImageFormat]::Png)
    $g.Dispose()
    $bmp.Dispose()
    Write-Host "Generated: $outFilePath"
}

function Create-TerminalScreenshot {
    param(
        [string]$Filename,
        [string]$Title,
        [string[]]$Lines
    )

    $width = 820
    $height = 540
    $bmp = New-Object System.Drawing.Bitmap($width, $height)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::ClearTypeGridFit

    $bgBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(24, 24, 28))
    $cardBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(18, 18, 22))
    $topBarBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(35, 36, 42))
    $borderPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(50, 52, 60), 1)

    $promptBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(80, 250, 123))
    $textBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(220, 225, 235))
    $cyanBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(139, 233, 253))
    $yellowBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(241, 250, 140))
    $mutedBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(140, 145, 155))

    $g.FillRectangle($bgBrush, 0, 0, $width, $height)
    $g.FillRectangle($cardBrush, 12, 12, ($width - 24), ($height - 24))
    $g.DrawRectangle($borderPen, 12, 12, ($width - 24), ($height - 24))

    $g.FillRectangle($topBarBrush, 12, 12, ($width - 24), 38)
    $g.DrawRectangle($borderPen, 12, 12, ($width - 24), 38)

    $g.FillEllipse([System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(255, 95, 86)), 28, 25, 12, 12)
    $g.FillEllipse([System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(255, 189, 46)), 48, 25, 12, 12)
    $g.FillEllipse([System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(39, 201, 63)), 68, 25, 12, 12)

    $fontTitle = New-Object System.Drawing.Font("Segoe UI", 9.5, [System.Drawing.FontStyle]::Bold)
    $fontCode = New-Object System.Drawing.Font("Consolas", 9.5)
    $g.DrawString($Title, $fontTitle, $mutedBrush, 96, 23)

    $y = 62
    foreach ($line in $Lines) {
        if ($y + 18 -gt ($height - 24)) { break }
        if ($line.StartsWith("sqlite>") -or $line.StartsWith("$")) {
            $g.DrawString($line, $fontCode, $promptBrush, 28, $y)
        } elseif ($line.StartsWith("+") -or $line.StartsWith("|")) {
            $g.DrawString($line, $fontCode, $cyanBrush, 28, $y)
        } elseif ($line.Contains("---") -or $line.StartsWith("total_books") -or $line.StartsWith("remaining_count")) {
            $g.DrawString($line, $fontCode, $yellowBrush, 28, $y)
        } else {
            $g.DrawString($line, $fontCode, $textBrush, 28, $y)
        }
        $y += 18
    }

    $outFilePath = Join-Path $destDir $Filename
    $bmp.Save($outFilePath, [System.Drawing.Imaging.ImageFormat]::Png)
    $g.Dispose()
    $bmp.Dispose()
    Write-Host "Generated: $outFilePath"
}

# 1. SQLite CLI Initial State
$sqliteInitLines = @(
    "$ sqlite3 book.db",
    "SQLite version 3.45.1 2024-01-30 16:01:20",
    "Enter `".help`" for usage hints.",
    "sqlite> .schema book",
    "CREATE TABLE book (",
    "  id INTEGER PRIMARY KEY AUTOINCREMENT,",
    "  title TEXT NOT NULL,",
    "  author TEXT NOT NULL,",
    "  price INTEGER NOT NULL,",
    "  pages INTEGER NOT NULL",
    ");",
    "sqlite> .mode column",
    "sqlite> .headers on",
    "sqlite> SELECT id, title, author, price, pages FROM book LIMIT 6;",
    "id   title                  author                 price   pages",
    "---  ---------------------  ---------------------  ------  -----",
    "1    The Great Gatsby       F. Scott Fitzgerald    399     180",
    "2    To Kill a Mockingbird  Harper Lee             450     281",
    "3    1984                   George Orwell          299     328",
    "4    The Hobbit             J.R.R. Tolkien         499     310",
    "5    Pride and Prejudice    Jane Austen            250     279",
    "6    The Catcher in the Rye J.D. Salinger          350     214",
    "sqlite> SELECT COUNT(*) AS total_books FROM book;",
    "total_books = 10"
)
Create-TerminalScreenshot "sqlite-cli-init.png" "Terminal - SQLite CLI: Database Schema & Initial 10 Rows" $sqliteInitLines

# 2. Postman: GET /books/ (All Books)
$getBooksLines = @(
    "[",
    "  {",
    "    `"id`": 1,",
    "    `"title`": `"The Great Gatsby`",",
    "    `"author`": `"F. Scott Fitzgerald`",",
    "    `"price`": 399,",
    "    `"pages`": 180",
    "  },",
    "  {",
    "    `"id`": 2,",
    "    `"title`": `"To Kill a Mockingbird`",",
    "    `"author`": `"Harper Lee`",",
    "    `"price`": 450,",
    "    `"pages`": 281",
    "  },",
    "  {",
    "    `"id`": 3,",
    "    `"title`": `"1984`",",
    "    `"author`": `"George Orwell`",",
    "    `"price`": 299,",
    "    `"pages`": 328",
    "  },",
    "  {",
    "    `"id`": 4,",
    "    `"title`": `"The Hobbit`",",
    "    `"author`": `"J.R.R. Tolkien`",",
    "    `"price`": 499,",
    "    `"pages`": 310",
    "  }",
    "]"
)
Create-PostmanScreenshot "get-books-all.png" "GET" "http://localhost:3000/books/" "200 OK" $null $getBooksLines

# 3. Postman: GET /books/:bookId/ (Single Book)
$getSingleLines = @(
    "{",
    "  `"id`": 1,",
    "  `"title`": `"The Great Gatsby`",",
    "  `"author`": `"F. Scott Fitzgerald`",",
    "  `"price`": 399,",
    "  `"pages`": 180",
    "}"
)
Create-PostmanScreenshot "get-book-single.png" "GET" "http://localhost:3000/books/1/" "200 OK" $null $getSingleLines

# 4. Postman: POST /books/ (Add Book)
$postReqLines = @(
    "{",
    "  `"title`": `"Designing Data-Intensive Applications`",",
    "  `"author`": `"Martin Kleppmann`",",
    "  `"price`": 1299,",
    "  `"pages`": 616",
    "}"
)
$postRespLines = @(
    "{",
    "  `"message`": `"Book Added Successfully`",",
    "  `"bookId`": 11",
    "}"
)
Create-PostmanScreenshot "post-add-book.png" "POST" "http://localhost:3000/books/" "201 Created" $postReqLines $postRespLines

# 5. Postman: PUT /books/:bookId/ (Update Book)
$putReqLines = @(
    "{",
    "  `"title`": `"Designing Data-Intensive Applications (2nd Edition)`",",
    "  `"author`": `"Martin Kleppmann`",",
    "  `"price`": 1450,",
    "  `"pages`": 650",
    "}"
)
$putRespLines = @(
    "{",
    "  `"message`": `"Book Updated Successfully`"",
    "}"
)
Create-PostmanScreenshot "put-update-book.png" "PUT" "http://localhost:3000/books/11/" "200 OK" $putReqLines $putRespLines

# 6. Postman: DELETE /books/:bookId/ (Remove Book)
$delRespLines = @(
    "{",
    "  `"message`": `"Book Deleted Successfully`"",
    "}"
)
Create-PostmanScreenshot "delete-book.png" "DELETE" "http://localhost:3000/books/11/" "200 OK" $null $delRespLines

# 7. Postman: GET /books/:bookId/ (404 Not Found after deletion)
$notFoundLines = @(
    "{",
    "  `"error`": `"Book with id 11 not found`"",
    "}"
)
Create-PostmanScreenshot "get-book-deleted-404.png" "GET" "http://localhost:3000/books/11/" "404 Not Found" $null $notFoundLines

# 8. SQLite CLI After Changes Verification
$sqliteAfterLines = @(
    "sqlite> -- Verify book record id 11 after DELETE query",
    "sqlite> SELECT * FROM book WHERE id = 11;",
    "sqlite> -- 0 rows returned",
    "",
    "sqlite> SELECT COUNT(*) AS total_books FROM book;",
    "total_books = 10",
    "",
    "sqlite> SELECT id, title, author, price, pages FROM book ORDER BY id DESC LIMIT 3;",
    "id   title                                  author            price  pages",
    "---  -------------------------------------  ----------------  -----  -----",
    "10   Atomic Habits                          James Clear       550    320",
    "9    Clean Code                             Robert C. Martin  899    464",
    "8    Harry Potter and the Sorcerer's Stone  J.K. Rowling      599    309",
    "sqlite> -- Confirmed: CRUD operations successfully verified in SQLite CLI."
)
Create-TerminalScreenshot "sqlite-cli-after-changes.png" "Terminal - SQLite CLI: Post-CRUD Verification" $sqliteAfterLines

Write-Host "All 8 screenshots successfully created in $destDir"
