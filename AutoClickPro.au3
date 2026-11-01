; ═══════════════════════════════════════════════════════════════
; AUTO CLICK PRO - Tự Động Bấm Chuột v3.5
; Hỗ trợ bấm 2 nút (LẬP LẠI + XÁC NHẬN)
; Có tính năng: GIỚI HẠN SỐ LẦN BẤM (Tự dừng khi đủ số lần)
; ═══════════════════════════════════════════════════════════════

#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <StaticConstants.au3>
#include <EditConstants.au3>
#include <ButtonConstants.au3>
#include <Misc.au3>

; ── Cài đặt hệ thống ────────────────────────────────────────
Opt("GUIOnEventMode", 0)
Opt("PixelCoordMode", 1)    ; Tọa độ theo màn hình
Opt("MouseCoordMode", 1)    ; Tọa độ theo màn hình
Opt("TrayIconHide", 0)

; ── Biến toàn cục ────────────────────────────────────────────
Global $configFile = @ScriptDir & "\config.ini"
Global $isRunning = False
Global $lastAction = 0
Global $lastDebugTime = 0
Global $clickCounter = 0

; ── Giá trị mặc định (theo đúng thông số thực tế của bạn) ────
Global $targetColor = 0x00530E
Global $colorTolerance = 5
Global $detect_x = 1584, $detect_y = 330
Global $point1_x = 1178, $point1_y = 1017
Global $point2_x = 1080, $point2_y = 1011
Global $cooldownTime = 15000
Global $delayP1P2 = 1500
Global $jitterMs = 50
Global $maxClicks = 300     ; 0 = không giới hạn, >0 = tự dừng khi đủ số lần

; ── Đọc cài đặt đã lưu ─────────────────────────────────────
LoadConfig()

; ── Đăng ký phím tắt ────────────────────────────────────────
HotKeySet("{F6}", "_HK_ToggleRun")
HotKeySet("{F7}", "_HK_PickColor")
HotKeySet("{F9}", "_HK_PickPoint1")
HotKeySet("{F10}", "_HK_PickPoint2")
HotKeySet("{ESC}", "_HK_Exit")

; ══════════════════════════════════════════════════════════════
; TẠO GIAO DIỆN
; ══════════════════════════════════════════════════════════════

Global $hGUI = GUICreate("AUTO CLICK PRO — Tự Động Bấm Chuột", 500, 660, -1, -1, BitOR($WS_SYSMENU, $WS_CAPTION, $WS_MINIMIZEBOX))
GUISetBkColor(0x1E1E2E)
GUISetFont(9, 400, 0, "Segoe UI")

; ── Tiêu đề ─────────────────────────────────────────────────
GUICtrlCreateLabel("AUTO CLICK PRO", 15, 10, 470, 28, $SS_CENTER)
GUICtrlSetFont(-1, 16, 700, 0, "Segoe UI")
GUICtrlSetColor(-1, 0x89B4FA)
GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)

GUICtrlCreateLabel("Tự động bấm chuột khi phát hiện màu xanh", 15, 38, 470, 18, $SS_CENTER)
GUICtrlSetFont(-1, 9, 400, 2, "Segoe UI")
GUICtrlSetColor(-1, 0x6C7086)
GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)

; ══════════════════════════════════════════════════════════════
; BƯỚC 1: CHỌN MÀU CẦN THEO DÕI
; ══════════════════════════════════════════════════════════════
_CreateSectionLabel("BƯỚC 1: CHỌN MÀU CẦN THEO DÕI", 15, 64)

GUICtrlCreateLabel("Bấm F7, chờ 3 giây, rồi di chuột đến chỗ có màu xanh trên màn hình", 25, 90, 450, 16)
GUICtrlSetFont(-1, 8, 400, 2, "Segoe UI")
GUICtrlSetColor(-1, 0x7F849C)
GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)

GUICtrlCreateLabel("Màu cần tìm:", 25, 115, 90, 20)
GUICtrlSetColor(-1, 0xCDD6F4)
GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
Global $inpColor = GUICtrlCreateInput("0x" & Hex($targetColor, 6), 120, 112, 90, 22)
GUICtrlSetBkColor(-1, 0x313244)
GUICtrlSetColor(-1, 0xA6E3A1)

Global $lblColorPreview = GUICtrlCreateLabel("", 218, 112, 22, 22, $SS_SUNKEN)
GUICtrlSetBkColor($lblColorPreview, $targetColor)

Global $btnPickColor = GUICtrlCreateButton("Lấy màu [F7]", 255, 110, 120, 26)

GUICtrlCreateLabel("Độ chênh màu cho phép:", 25, 145, 150, 20)
GUICtrlSetColor(-1, 0xCDD6F4)
GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
Global $inpTolerance = GUICtrlCreateInput($colorTolerance, 180, 142, 40, 22, $ES_NUMBER)
GUICtrlSetBkColor(-1, 0x313244)
GUICtrlSetColor(-1, 0xFAB387)
GUICtrlCreateLabel("(0-50, mặc định 5 là đủ)", 228, 145, 180, 18)
GUICtrlSetFont(-1, 8, 400, 2, "Segoe UI")
GUICtrlSetColor(-1, 0x585B70)
GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)

GUICtrlCreateLabel("Vị trí theo dõi màu:", 25, 175, 130, 20)
GUICtrlSetColor(-1, 0xCDD6F4)
GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
GUICtrlCreateLabel("X", 160, 175, 12, 20)
GUICtrlSetColor(-1, 0x9399B2)
GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
Global $inpDetectX = GUICtrlCreateInput($detect_x, 173, 172, 55, 22, $ES_NUMBER)
GUICtrlSetBkColor(-1, 0x313244)
GUICtrlSetColor(-1, 0xCDD6F4)
GUICtrlCreateLabel("Y", 237, 175, 12, 20)
GUICtrlSetColor(-1, 0x9399B2)
GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
Global $inpDetectY = GUICtrlCreateInput($detect_y, 250, 172, 55, 22, $ES_NUMBER)
GUICtrlSetBkColor(-1, 0x313244)
GUICtrlSetColor(-1, 0xCDD6F4)

Global $btnPickDetect = GUICtrlCreateButton("Chỉ vị trí", 320, 170, 80, 26)

; ══════════════════════════════════════════════════════════════
; BƯỚC 2: CHỌN VỊ TRÍ CẦN BẤM
; ══════════════════════════════════════════════════════════════
_CreateSectionLabel("BƯỚC 2: CHỌN VỊ TRÍ CẦN BẤM", 15, 205)

GUICtrlCreateLabel("Bấm F9/F10, chờ 3 giây, rồi di chuột đến nút cần bấm trên màn hình", 25, 231, 450, 16)
GUICtrlSetFont(-1, 8, 400, 2, "Segoe UI")
GUICtrlSetColor(-1, 0x7F849C)
GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)

GUICtrlCreateLabel("Nút bấm thứ 1 (LẬP LẠI):", 25, 256, 165, 20)
GUICtrlSetColor(-1, 0xCDD6F4)
GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
GUICtrlCreateLabel("X", 195, 256, 12, 20)
GUICtrlSetColor(-1, 0x9399B2)
GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
Global $inpP1X = GUICtrlCreateInput($point1_x, 208, 253, 50, 22, $ES_NUMBER)
GUICtrlSetBkColor(-1, 0x313244)
GUICtrlSetColor(-1, 0xCDD6F4)
GUICtrlCreateLabel("Y", 267, 256, 12, 20)
GUICtrlSetColor(-1, 0x9399B2)
GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
Global $inpP1Y = GUICtrlCreateInput($point1_y, 280, 253, 50, 22, $ES_NUMBER)
GUICtrlSetBkColor(-1, 0x313244)
GUICtrlSetColor(-1, 0xCDD6F4)

Global $btnPickP1 = GUICtrlCreateButton("Chỉ vị trí [F9]", 345, 251, 110, 26)

GUICtrlCreateLabel("Nút bấm thứ 2 (XÁC NHẬN):", 25, 286, 170, 20)
GUICtrlSetColor(-1, 0xCDD6F4)
GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
GUICtrlCreateLabel("X", 195, 286, 12, 20)
GUICtrlSetColor(-1, 0x9399B2)
GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
Global $inpP2X = GUICtrlCreateInput($point2_x, 208, 283, 50, 22, $ES_NUMBER)
GUICtrlSetBkColor(-1, 0x313244)
GUICtrlSetColor(-1, 0xCDD6F4)
GUICtrlCreateLabel("Y", 267, 286, 12, 20)
GUICtrlSetColor(-1, 0x9399B2)
GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
Global $inpP2Y = GUICtrlCreateInput($point2_y, 280, 283, 50, 22, $ES_NUMBER)
GUICtrlSetBkColor(-1, 0x313244)
GUICtrlSetColor(-1, 0xCDD6F4)

Global $btnPickP2 = GUICtrlCreateButton("Chỉ vị trí [F10]", 345, 281, 110, 26)

; ══════════════════════════════════════════════════════════════
; BƯỚC 3: CÀI ĐẶT THỜI GIAN & GIỚI HẠN SỐ LẦN
; ══════════════════════════════════════════════════════════════
_CreateSectionLabel("BƯỚC 3: CÀI ĐẶT THỜI GIAN & GIỚI HẠN SỐ LẦN", 15, 318)

GUICtrlCreateLabel("Thời gian chờ giữa mỗi lần (giây):", 25, 345, 210, 20)
GUICtrlSetColor(-1, 0xCDD6F4)
GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
Global $inpCooldown = GUICtrlCreateInput($cooldownTime / 1000, 240, 342, 45, 22, $ES_NUMBER)
GUICtrlSetBkColor(-1, 0x313244)
GUICtrlSetColor(-1, 0xF9E2AF)
GUICtrlCreateLabel("(VD: 15 = cứ 15 giây bấm 1 lần)", 295, 345, 195, 18)
GUICtrlSetFont(-1, 8, 400, 2, "Segoe UI")
GUICtrlSetColor(-1, 0x585B70)
GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)

GUICtrlCreateLabel("Chờ giữa 2 lần bấm (mili-giây):", 25, 373, 210, 20)
GUICtrlSetColor(-1, 0xCDD6F4)
GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
Global $inpDelay = GUICtrlCreateInput($delayP1P2, 240, 370, 45, 22, $ES_NUMBER)
GUICtrlSetBkColor(-1, 0x313244)
GUICtrlSetColor(-1, 0xF9E2AF)
GUICtrlCreateLabel("(1500 = 1.5 giây, không cần đổi)", 295, 373, 195, 18)
GUICtrlSetFont(-1, 8, 400, 2, "Segoe UI")
GUICtrlSetColor(-1, 0x585B70)
GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)

GUICtrlCreateLabel("Dao động ngẫu nhiên (mili-giây):", 25, 401, 210, 20)
GUICtrlSetColor(-1, 0xCDD6F4)
GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
Global $inpJitter = GUICtrlCreateInput($jitterMs, 240, 398, 45, 22, $ES_NUMBER)
GUICtrlSetBkColor(-1, 0x313244)
GUICtrlSetColor(-1, 0xF9E2AF)
GUICtrlCreateLabel("(để bấm tự nhiên hơn, không cần đổi)", 295, 401, 195, 18)
GUICtrlSetFont(-1, 8, 400, 2, "Segoe UI")
GUICtrlSetColor(-1, 0x585B70)
GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)

; --- MỤC MỚI: GIỚI HẠN SỐ LẦN BẤM ---
GUICtrlCreateLabel("🎯 Giới hạn số lần bấm:", 25, 429, 210, 20)
GUICtrlSetFont(-1, 9, 700)
GUICtrlSetColor(-1, 0xA6E3A1)
GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
Global $inpMaxClicks = GUICtrlCreateInput($maxClicks, 240, 426, 50, 22, $ES_NUMBER)
GUICtrlSetBkColor(-1, 0x313244)
GUICtrlSetColor(-1, 0xA6E3A1)
GUICtrlSetFont(-1, 9, 700)
GUICtrlCreateLabel("(Ví dụ: 300 lần sẽ tự dừng. 0 = vô hạn)", 295, 429, 195, 18)
GUICtrlSetFont(-1, 8, 400, 2, "Segoe UI")
GUICtrlSetColor(-1, 0x89DCEB)
GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)

; ── Nút điều khiển ───────────────────────────────────────────
Global $btnStart = GUICtrlCreateButton("BẮT ĐẦU [F6]", 15, 465, 150, 45)
GUICtrlSetFont(-1, 12, 700)

Global $btnSave = GUICtrlCreateButton("LƯU CÀI ĐẶT", 175, 465, 150, 45)
GUICtrlSetFont(-1, 10, 600)

Global $btnExit = GUICtrlCreateButton("THOÁT [ESC]", 335, 465, 150, 45)
GUICtrlSetFont(-1, 10, 600)

; ── Thanh trạng thái ─────────────────────────────────────────
GUICtrlCreateLabel("", 15, 520, 470, 2, $SS_ETCHEDHORZ)

Global $lblStatus = GUICtrlCreateLabel("● CHƯA CHẠY — Bấm F6 để bắt đầu", 15, 530, 470, 20)
GUICtrlSetColor(-1, 0xA6ADC8)
GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
GUICtrlSetFont(-1, 9, 600, 0, "Segoe UI")

Global $lblDetect = GUICtrlCreateLabel("Đang theo dõi: —", 15, 555, 470, 20)
GUICtrlSetColor(-1, 0x585B70)
GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
GUICtrlSetFont(-1, 8, 400, 0, "Consolas")

Global $lblClickCount = GUICtrlCreateLabel("Số lần đã bấm: 0 / 300", 15, 577, 360, 22)
GUICtrlSetColor(-1, 0xF9E2AF)
GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
GUICtrlSetFont(-1, 9, 700, 0, "Consolas")

Global $btnResetCount = GUICtrlCreateButton("Đặt lại 0", 385, 574, 90, 24)
GUICtrlSetFont(-1, 8, 400)

GUICtrlCreateLabel("Phím tắt: F6=Bắt đầu/Dừng | F7=Lấy màu | F9=Chỉ nút 1 | F10=Chỉ nút 2 | ESC=Thoát", 15, 605, 470, 16)
GUICtrlSetFont(-1, 7, 400, 0, "Segoe UI")
GUICtrlSetColor(-1, 0x45475A)
GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)

_UpdateClickCountDisplay()
GUISetState(@SW_SHOW)

; ══════════════════════════════════════════════════════════════
; VÒNG LẶP CHÍNH
; ══════════════════════════════════════════════════════════════

While 1
    Local $msg = GUIGetMsg()
    Switch $msg
        Case $GUI_EVENT_CLOSE
            _DoExit()
        Case $btnStart
            _ToggleRun()
        Case $btnSave
            _ReadGUIToVars()
            SaveConfig()
            _SetStatus("Đã lưu cài đặt!", 0xA6E3A1)
        Case $btnExit
            _DoExit()
        Case $btnPickColor
            _PickColor()
        Case $btnPickDetect
            _PickPosition(1)
        Case $btnPickP1
            _PickPosition(2)
        Case $btnPickP2
            _PickPosition(3)
        Case $btnResetCount
            $clickCounter = 0
            _UpdateClickCountDisplay()
            _SetStatus("Đã đặt lại số lần bấm về 0", 0x89B4FA)
    EndSwitch

    ; ── Logic tự động bấm ────────────────────────────────────
    If $isRunning Then
        ; Cập nhật thông tin theo dõi mỗi 500ms
        If TimerDiff($lastDebugTime) > 500 Then
            Local $curColor = PixelGetColor($detect_x, $detect_y)
            GUICtrlSetData($lblDetect, "Đang theo dõi: 0x" & Hex($curColor, 6) & " tại (" & $detect_x & "," & $detect_y & ") | Cần tìm: 0x" & Hex($targetColor, 6))
            $lastDebugTime = TimerInit()
        EndIf

        ; Kiểm tra xem đã đủ thời gian chờ (cooldown) chưa
        If TimerDiff($lastAction) > $cooldownTime Then
            Local $currentColor = PixelGetColor($detect_x, $detect_y)

            If _IsColorMatch($currentColor, $targetColor, $colorTolerance) Then
                ConsoleWrite(@CRLF & ">>> THẤY MÀU XANH! Đang bấm..." & @CRLF)
                _SetStatus("THẤY MÀU XANH! Đang bấm...", 0xF38BA8)

                $lastAction = TimerInit()
                _PerformClickSequence()
                $clickCounter += 1
                _UpdateClickCountDisplay()

                ; KIỂM TRA ĐÃ ĐẠT GIỚI HẠN SỐ LẦN CHƯA
                If $maxClicks > 0 And $clickCounter >= $maxClicks Then
                    $isRunning = False
                    GUICtrlSetData($btnStart, "BẮT ĐẦU [F6]")
                    _SetStatus("🎉 ĐÃ HOÀN THÀNH — Đã bấm đủ " & $maxClicks & " lần!", 0xA6E3A1)
                    ConsoleWrite(@CRLF & ">>> ĐÃ ĐẠT GIỚI HẠN " & $maxClicks & " LẦN! TỰ ĐỘNG DỪNG LẠI." & @CRLF)
                    Beep(1000, 300)
                    Sleep(100)
                    Beep(1500, 500)
                Else
                    _SetStatus("ĐANG CHẠY — Chờ " & ($cooldownTime / 1000) & " giây trước lần tiếp...", 0xA6E3A1)
                    ConsoleWrite(">>> Xong! Chờ " & ($cooldownTime / 1000) & " giây..." & @CRLF & @CRLF)
                EndIf
            EndIf
        Else
            ; Hiển thị thời gian chờ còn lại
            Local $remaining = Int(($cooldownTime - TimerDiff($lastAction)) / 1000)
            If $remaining >= 0 Then
                _SetStatus("▶ ĐANG CHẠY — Chờ " & $remaining & " giây nữa...", 0xF9E2AF)
            EndIf
        EndIf
    EndIf

    Sleep(30)
WEnd

; ══════════════════════════════════════════════════════════════
; CÁC HÀM XỬ LÝ
; ══════════════════════════════════════════════════════════════

Func _UpdateClickCountDisplay()
    If $maxClicks > 0 Then
        GUICtrlSetData($lblClickCount, "Số lần đã bấm: " & $clickCounter & " / " & $maxClicks)
    Else
        GUICtrlSetData($lblClickCount, "Số lần đã bấm: " & $clickCounter & " (Không giới hạn)")
    EndIf
EndFunc

Func _IsColorMatch($color1, $color2, $tolerance = 0)
    If $tolerance = 0 Then Return $color1 = $color2

    Local $r1 = BitAND(BitShift($color1, 16), 0xFF)
    Local $g1 = BitAND(BitShift($color1, 8), 0xFF)
    Local $b1 = BitAND($color1, 0xFF)

    Local $r2 = BitAND(BitShift($color2, 16), 0xFF)
    Local $g2 = BitAND(BitShift($color2, 8), 0xFF)
    Local $b2 = BitAND($color2, 0xFF)

    Return (Abs($r1 - $r2) <= $tolerance) And (Abs($g1 - $g2) <= $tolerance) And (Abs($b1 - $b2) <= $tolerance)
EndFunc

Func _PerformClickSequence()
    ; Bấm nút thứ 1 (LẬP LẠI)
    ConsoleWrite("  → Bấm nút 1 (LẬP LẠI): (" & $point1_x & "," & $point1_y & ")" & @CRLF)
    MouseClick("left", $point1_x, $point1_y, 1, Random(8, 15, 1))
    _JitterSleep($delayP1P2, $jitterMs)

    ; Bấm nút thứ 2 (XÁC NHẬN)
    ConsoleWrite("  → Bấm nút 2 (XÁC NHẬN): (" & $point2_x & "," & $point2_y & ")" & @CRLF)
    MouseClick("left", $point2_x, $point2_y, 1, Random(8, 15, 1))
    _JitterSleep(500, $jitterMs)
EndFunc

Func _JitterSleep($baseMs, $jitter)
    Local $actual = $baseMs + Random(-$jitter, $jitter, 1)
    If $actual < 10 Then $actual = 10
    Sleep($actual)
EndFunc

Func _ToggleRun()
    If $isRunning Then
        $isRunning = False
        GUICtrlSetData($btnStart, "BẮT ĐẦU [F6]")
        _SetStatus("● ĐÃ DỪNG — Bấm F6 để chạy lại", 0xA6ADC8)
        ConsoleWrite("=== ĐÃ DỪNG ===" & @CRLF)
    Else
        _ReadGUIToVars()
        
        ; Nếu đã bấm đủ số lần trước đó, tự động đặt lại về 0 để chạy vòng mới
        If $maxClicks > 0 And $clickCounter >= $maxClicks Then
            $clickCounter = 0
            _UpdateClickCountDisplay()
        EndIf

        $isRunning = True
        $lastAction = 0
        $lastDebugTime = 0
        GUICtrlSetData($btnStart, "DỪNG LẠI [F6]")
        _SetStatus("▶ ĐANG CHẠY — Đang tìm màu xanh...", 0xA6E3A1)
        ConsoleWrite("=== BẮT ĐẦU === Giới hạn: " & $maxClicks & " lần | Tìm màu: 0x" & Hex($targetColor, 6) & @CRLF)
    EndIf
EndFunc

Func _PickColor()
    _SetStatus("Di chuột đến chỗ có MÀU XANH...", 0x89B4FA)
    GUISetState(@SW_MINIMIZE)

    For $i = 3 To 1 Step -1
        ToolTip("Di chuột đến chỗ có MÀU XANH trong " & $i & " giây...", 0, 0, "Lấy màu", 1)
        Sleep(1000)
    Next
    ToolTip("")

    Local $pos = MouseGetPos()
    Local $color = PixelGetColor($pos[0], $pos[1])

    GUICtrlSetData($inpColor, "0x" & Hex($color, 6))
    GUICtrlSetData($inpDetectX, $pos[0])
    GUICtrlSetData($inpDetectY, $pos[1])
    GUICtrlSetBkColor($lblColorPreview, $color)

    $targetColor = $color
    $detect_x = $pos[0]
    $detect_y = $pos[1]

    GUISetState(@SW_RESTORE)
    _SetStatus("Đã lấy màu: 0x" & Hex($color, 6) & " tại (" & $pos[0] & "," & $pos[1] & ")", 0xA6E3A1)
EndFunc

Func _PickPosition($mode)
    Local $label = ""
    Switch $mode
        Case 1
            $label = "vị trí theo dõi màu"
        Case 2
            $label = "nút bấm thứ 1 (LẬP LẠI)"
        Case 3
            $label = "nút bấm thứ 2 (XÁC NHẬN)"
    EndSwitch

    _SetStatus("Di chuột đến " & $label & "...", 0x89B4FA)
    GUISetState(@SW_MINIMIZE)

    For $i = 3 To 1 Step -1
        ToolTip("Di chuột đến " & $label & " trong " & $i & " giây...", 0, 0, "Chỉ vị trí", 1)
        Sleep(1000)
    Next
    ToolTip("")

    Local $pos = MouseGetPos()

    Switch $mode
        Case 1
            GUICtrlSetData($inpDetectX, $pos[0])
            GUICtrlSetData($inpDetectY, $pos[1])
            $detect_x = $pos[0]
            $detect_y = $pos[1]
        Case 2
            GUICtrlSetData($inpP1X, $pos[0])
            GUICtrlSetData($inpP1Y, $pos[1])
            $point1_x = $pos[0]
            $point1_y = $pos[1]
        Case 3
            GUICtrlSetData($inpP2X, $pos[0])
            GUICtrlSetData($inpP2Y, $pos[1])
            $point2_x = $pos[0]
            $point2_y = $pos[1]
    EndSwitch

    GUISetState(@SW_RESTORE)
    _SetStatus("Đã lấy " & $label & ": (" & $pos[0] & "," & $pos[1] & ")", 0xA6E3A1)
EndFunc

Func _ReadGUIToVars()
    Local $colorStr = GUICtrlRead($inpColor)
    If StringLeft($colorStr, 2) = "0x" Or StringLeft($colorStr, 2) = "0X" Then
        $targetColor = Int($colorStr)
    Else
        $targetColor = Int("0x" & $colorStr)
    EndIf
    GUICtrlSetBkColor($lblColorPreview, $targetColor)

    $colorTolerance = Int(GUICtrlRead($inpTolerance))
    $detect_x = Int(GUICtrlRead($inpDetectX))
    $detect_y = Int(GUICtrlRead($inpDetectY))
    $point1_x = Int(GUICtrlRead($inpP1X))
    $point1_y = Int(GUICtrlRead($inpP1Y))
    $point2_x = Int(GUICtrlRead($inpP2X))
    $point2_y = Int(GUICtrlRead($inpP2Y))
    $cooldownTime = Int(GUICtrlRead($inpCooldown)) * 1000
    $delayP1P2 = Int(GUICtrlRead($inpDelay))
    $jitterMs = Int(GUICtrlRead($inpJitter))
    $maxClicks = Int(GUICtrlRead($inpMaxClicks))
    _UpdateClickCountDisplay()
EndFunc

Func LoadConfig()
    If Not FileExists($configFile) Then Return

    $targetColor = Int(IniRead($configFile, "Detection", "Color", "0x00530E"))
    $colorTolerance = Int(IniRead($configFile, "Detection", "Tolerance", "5"))
    $detect_x = Int(IniRead($configFile, "Detection", "DetectX", "1584"))
    $detect_y = Int(IniRead($configFile, "Detection", "DetectY", "330"))
    $point1_x = Int(IniRead($configFile, "ClickPoints", "P1X", "1178"))
    $point1_y = Int(IniRead($configFile, "ClickPoints", "P1Y", "1017"))
    $point2_x = Int(IniRead($configFile, "ClickPoints", "P2X", "1080"))
    $point2_y = Int(IniRead($configFile, "ClickPoints", "P2Y", "1011"))
    $cooldownTime = Int(IniRead($configFile, "Timing", "CooldownMs", "15000"))
    $delayP1P2 = Int(IniRead($configFile, "Timing", "DelayP1P2", "1500"))
    $jitterMs = Int(IniRead($configFile, "Timing", "JitterMs", "50"))
    $maxClicks = Int(IniRead($configFile, "Settings", "MaxClicks", "300"))
EndFunc

Func SaveConfig()
    IniWrite($configFile, "Detection", "Color", "0x" & Hex($targetColor, 6))
    IniWrite($configFile, "Detection", "Tolerance", $colorTolerance)
    IniWrite($configFile, "Detection", "DetectX", $detect_x)
    IniWrite($configFile, "Detection", "DetectY", $detect_y)
    IniWrite($configFile, "ClickPoints", "P1X", $point1_x)
    IniWrite($configFile, "ClickPoints", "P1Y", $point1_y)
    IniWrite($configFile, "ClickPoints", "P2X", $point2_x)
    IniWrite($configFile, "ClickPoints", "P2Y", $point2_y)
    IniWrite($configFile, "Timing", "CooldownMs", $cooldownTime)
    IniWrite($configFile, "Timing", "DelayP1P2", $delayP1P2)
    IniWrite($configFile, "Timing", "JitterMs", $jitterMs)
    IniWrite($configFile, "Settings", "MaxClicks", $maxClicks)
EndFunc

Func _SetStatus($text, $color)
    GUICtrlSetData($lblStatus, $text)
    GUICtrlSetColor($lblStatus, $color)
EndFunc

Func _CreateSectionLabel($text, $x, $y)
    GUICtrlCreateLabel($text, $x, $y, 470, 18)
    GUICtrlSetFont(-1, 9, 700, 0, "Segoe UI")
    GUICtrlSetColor(-1, 0x89B4FA)
    GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
    GUICtrlCreateLabel("", $x, $y + 20, 470, 1, $SS_ETCHEDHORZ)
EndFunc

Func _DoExit()
    _ReadGUIToVars()
    SaveConfig()
    GUIDelete()
    Exit
EndFunc

Func _HK_ToggleRun()
    _ToggleRun()
EndFunc

Func _HK_PickColor()
    _PickColor()
EndFunc

Func _HK_PickPoint1()
    _PickPosition(2)
EndFunc

Func _HK_PickPoint2()
    _PickPosition(3)
EndFunc

Func _HK_Exit()
    _DoExit()
EndFunc
