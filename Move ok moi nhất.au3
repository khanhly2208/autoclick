; Auto Click Script - Version 2.0
; Phát hiện màu xanh liên tục và click 2 điểm

; Cấu hình
Global $targetColor = 0x0012605  ; Màu xanh cần tìm
Global $colorTolerance = 5       ; Độ sai lệch màu cho phép

; Tọa độ
Global $detect_x = 1146, $detect_y = 166
Global $point1_x = 827, $point1_y = 705  
Global $point2_x = 749, $point2_y = 707

; Trạng thái
Global $lastAction = 0  ; Thời điểm action cuối cùng
Global $cooldownTime = 15000  ; Thời gian chờ giữa các lần click (15 giây)

ConsoleWrite("=== AUTO CLICK SCRIPT STARTED ===" & @CRLF)
ConsoleWrite("Target Color: 0x" & Hex($targetColor) & @CRLF)
ConsoleWrite("Detect Position: " & $detect_x & "," & $detect_y & @CRLF)
ConsoleWrite("Cooldown: " & $cooldownTime & "ms" & @CRLF & @CRLF)

; Biến debug global
Global $lastDebug = 0

While 1
    $currentColor = PixelGetColor($detect_x, $detect_y)
    $currentTime = TimerInit()
    
    ; Hiển thị màu hiện tại mỗi 2 giây để debug
    If TimerDiff($lastDebug) > 2000 Then
        ConsoleWrite("Current Color: 0x" & Hex($currentColor) & " | Target: 0x" & Hex($targetColor) & @CRLF)
        $lastDebug = TimerInit()
    EndIf
    
    ; Kiểm tra xem đã đủ thời gian cooldown chưa
    If TimerDiff($lastAction) > $cooldownTime Then
        
        ; Kiểm tra màu có khớp không (với tolerance)
        If IsColorMatch($currentColor, $targetColor, $colorTolerance) Then
            ConsoleWrite(@CRLF & ">>> PHÁT HIỆN MÀU XANH! Bắt đầu sequence..." & @CRLF)
            
            ; Cập nhật thời gian action ngay lập tức để tránh click trùng lặp
            $lastAction = TimerInit()
            
            ; Thực hiện sequence click
            PerformClickSequence()
            
            ConsoleWrite(">>> Hoàn thành! Đợi " & ($cooldownTime/1000) & " giây trước lần tiếp theo..." & @CRLF & @CRLF)
        EndIf
    Else
        ; Hiển thị thời gian còn lại trong cooldown
        Local $remainingTime = Int(($cooldownTime - TimerDiff($lastAction)) / 1000)
        If $remainingTime > 0 And TimerDiff($lastDebug) > 2000 Then
            ConsoleWrite("Đang trong thời gian chờ: còn " & $remainingTime & " giây..." & @CRLF)
        EndIf
    EndIf
    
    Sleep(50)  ; Kiểm tra mỗi 50ms
WEnd

; Hàm kiểm tra màu có khớp không (với tolerance)
Func IsColorMatch($color1, $color2, $tolerance = 0)
    If $tolerance = 0 Then Return $color1 = $color2
    
    Local $r1 = BitAND(BitShift($color1, 16), 0xFF)
    Local $g1 = BitAND(BitShift($color1, 8), 0xFF) 
    Local $b1 = BitAND($color1, 0xFF)
    
    Local $r2 = BitAND(BitShift($color2, 16), 0xFF)
    Local $g2 = BitAND(BitShift($color2, 8), 0xFF)
    Local $b2 = BitAND($color2, 0xFF)
    
    Return (Abs($r1-$r2) <= $tolerance) And (Abs($g1-$g2) <= $tolerance) And (Abs($b1-$b2) <= $tolerance)
EndFunc

; Hàm thực hiện click sequence
Func PerformClickSequence()
    ; Click điểm 1
    ConsoleWrite("  → Click điểm 1: (" & $point1_x & "," & $point1_y & ")" & @CRLF)
    MouseClick("left", $point1_x, $point1_y, 1, 10)
    Sleep(1500)
    
    ; Click điểm 2
    ConsoleWrite("  → Click điểm 2: (" & $point2_x & "," & $point2_y & ")" & @CRLF)  
    MouseClick("left", $point2_x, $point2_y, 1, 10)
    Sleep(500)
EndFunc