#!/bin/bash

function generatejdkdeps() {
  echo "Generating JDK deps"
  $JAVA_HOME/bin/java --list-modules > java-modules.txt
  < java-modules.txt sed "s/\\@.*//" > modules.txt
  grep -Fx -f stripped-deps.txt modules.txt | tr '\n' ',' | tr -d "[:space:]" > module-deps.txt
  echo "jdk.zipfs" >> module-deps.txt
}