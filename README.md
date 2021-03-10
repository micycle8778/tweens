# tweens
tweens is a basic tweening library for Nim. 

You can install it just like any other nimble library. Get 
[choosenim](https://github.com/dom96/choosenim),
and run `nimble install tweens`.

The documentation was written
[here](https://rainbowasteroids.github.io/tweens//tweens.html), so for now, 
I'll just show [an example](https://github.com/RainbowAsteroids/tweens/blob/master/tests/test.nim)
you can run by doing `nimble test`:

```nim
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
```
