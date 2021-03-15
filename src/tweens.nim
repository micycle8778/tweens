## Basic tweening library for Nim
##
## First you should select the preferred easing function (and any parameters 
## if applicable) from the list found in [TweenKind](#TweenKind).
##
## Next, instance your tween using [createTween](#createTween,TweenKind,float,float,Natural,int)
## procedure
##
## Finally, run a loop until `t.step == t.steps`, incrementing your tween in
## every interation.
##
## Example:
## ```nim
## import strutils
## import math
## import os
## import tweens
##
## var t = createTween(tkEaseIn, 0, 180, 90)
## 
## while t.step != t.steps:
##     stdout.write("\x1b[2K\x1b[u" & "=".repeat(round(t.val).Natural))
##     stdout.flushFile()
##
##     sleep(50)
## 
##     inc t
## 
## echo()
## ```

import math

type 
    EasingFunction = proc(start, goal, perc: float): float
    TweenKind* = enum
        ## The types of easing functions a tween could have.
        tkLinear, tkEaseIn, tkEaseOut, tkEaseInOut, tkCustom

    Tween* = object
        ## The actual tween object. Should be created by
        ## [createTween](#createTween,TweenKind,float,float,Natural,int)
        start: float
        goal: float
        val*: float
        step*: Natural 
        steps*: Natural
        case kind: TweenKind
        of tkLinear: discard
        of tkEaseIn, tkEaseOut: p: int ## Parameter for easeIn and easeOut
        of tkEaseInOut: p1, p2: int ## Parameters for easeInOut
        of tkCustom: fn: EasingFunction 

func lerp*(start, goal, perc: float): float =
    ## Basic linear interpolation. When `perc` is some value between zero and one,
    ## `lerp` will return `start` plus a percentage of the difference between
    ## `start` and `end`.
    ## If you increase `perc`, you will see your output grow linearly.
    ##
    ## [Desmos graph](https://www.desmos.com/calculator/iytbrpz5c5)
    start + (goal - start) * perc

func easeIn(x: float, p = 2): float = 
    pow(x, p.float)
func easeIn*(start, goal, perc: float, p = 2): float =
    ## Like [lerp](#lerp,float,float,float), except the rate of increase is 
    ## higher the higher `perc` 
    ## becomes. `p` is the exponent passed to `easeIn`, making the function's
    ## rapid increase later and more prevelent with higher `p` values.
    ##
    ## [Desmos graph](https://www.desmos.com/calculator/ain22cxoyx)
    lerp(start, goal, easeIn(perc, p))

func flip(x: float): float = 
    1 - x
func easeOut(x: float, p = 2): float = 
    flip(easeIn(flip(x), p))
func easeOut*(start, goal, perc: float, p = 2): float =
    ## Opposite of [easeIn](#easeIn,float,float,float,int). Instead of
    ## the rate of increase being higher with higher values of `perc`,
    ## the rate of increase slows down with higher values of `perc`. `p` still
    ## has the same effect.
    ##
    ## [Desmos graph](https://www.desmos.com/calculator/0xp9wkdm1l)
    lerp(start, goal, easeOut(perc, p))

func easeInOut(x: float, p1 = 2, p2 = 2): float =
    lerp(easeIn(x, p1), easeOut(x, p2), x)
func easeInOut*(start, goal, perc: float, p1 = 2, p2 = 2): float =
    ## A mix between [easeIn](#easeIn,float,float,float,int) and 
    ## [easeOut](#easeOut,float,float,float,int). Starts off slow,
    ## speeds up, and then slows down again. `p1` goes to `easeIn` and
    ## `p2` goes to `easeOut`.
    ##
    ## [Desmos graph](https://www.desmos.com/calculator/st399mrg1o)
    lerp(start, goal, easeInOut(perc, p1, p2))

proc init(t: var Tween, start, goal: float, steps: Natural) =
    t.start = start
    t.val = start
    t.goal = goal
    t.steps = steps
    t.step = 0

proc createTween*(kind: TweenKind, start, goal: float, 
                     steps: Natural, p = 2, p2 = p): Tween =
    ## Creates a [Tween](#Tween). This should be used instead of the default
    ## constructor. `p` is passed into `easeIn` and `easeOut`. `p` and `p2` are
    ## passed into `easeInOut` on the `easeIn` side and `easeOut` side
    ## respectively.
    case kind:
        of tkLinear:
            result = Tween(kind: kind)
        of tkEaseIn, tkEaseOut:
            result = Tween(kind: kind, p: p)
        of tkEaseInOut:
            result = Tween(kind: kind, p1: p, p2: p2)
        of tkCustom:
            assert false

    result.init(start, goal, steps)

proc createTween*(fn: EasingFunction, start, goal: float, 
            steps: Natural): Tween =
    result = Tween(kind: tkCustom, fn: fn)

    result.init(start, goal, steps)

proc set*(t: var Tween) =
    ## Set the value of a [Tween](#Tween) according to the easing function it 
    ## needs Should only be used if you decide
    ## to set the tween's `step` without using [inc](#inc,Tween) or 
    ## [dec](#dec,Tween).
    let perc = t.step / t.steps
    case t.kind:
        of tkLinear:
            t.val = lerp(t.start, t.goal, perc)
        of tkEaseIn:
            t.val = easeIn(t.start, t.goal, perc, t.p)
        of tkEaseOut:
            t.val = easeOut(t.start, t.goal, perc, t.p)
        of tkEaseInOut:
            t.val = easeInOut(t.start, t.goal, perc, t.p1, t.p2)
        of tkCustom:
            t.val = t.fn(t.start, t.goal, perc)

proc inc*(t: var Tween, amt = 1.Natural) =
    ## Increment `t.step` by `amt` and set the value of the tween.
    ## Prevents `t.step` from going higher than the max, `t.steps`, so this
    ## should be the preferred way of changing `t.step`.
    t.step = min(t.steps, t.step + amt)
    t.set()

proc dec*(t: var Tween, amt = 1.Natural) =
    ## Decrement `t.step` by `amt` and set the value of the tween.
    ## Prevents `t.step` from going below zero, so this should be the
    ## preferred way of changing `t.step`.
    t.step = max(0, t.step - amt)
    t.set()
