#!/bin/bash

count=10

for x in `seq -w 1 $count`; do
    vault namespace create ns${x}
done


