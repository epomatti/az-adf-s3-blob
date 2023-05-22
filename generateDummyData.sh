#!/bin/bash

dummydata="dummydata"

rm -rf $dummydata
mkdir $dummydata

for i in {1..5000}
do
   cp order-template.json ./$dummydata/order$i.json
done
