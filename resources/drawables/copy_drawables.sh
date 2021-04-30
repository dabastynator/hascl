#!/bin/bash
for i in ../../resources*/drawables; do echo $i; cp drawables.xml $i/; done;
