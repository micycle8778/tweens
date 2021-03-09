import strutils
import math
import os
import tweens
var t = createTween(tkEaseIn, 0, 180, 90)

while t.step != t.steps:
    stdout.write("\x1b[2K\x1b[u" & "=".repeat(round(t.val).Natural))
    stdout.flushFile()
    
    sleep(50)

    inc t

echo()
