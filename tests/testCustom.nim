import tweens
import os

func customFunction(start, goal, perc: float): float =
    if perc > 0.7: goal
    else: start 

var t = createTween(customFunction, 0, 100, 100)

while t.step != t.steps:
    echo "Step: ", t.step, " Value: ", t.val

    sleep(50)

    inc t
