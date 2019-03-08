#!/bin/bash

countx=3
county=3
countz=3

for x in `seq -w 1 $countx`; do
    vault namespace create ns${x} 
    for y in `seq -w 1 $county`; do
        vault namespace create -namespace=ns${x} ns${y}
        for z in `seq -w 1 $countz`; do
            vault namespace create -namespace=ns${x}/ns${y} ns${z}
        done
    done
done


