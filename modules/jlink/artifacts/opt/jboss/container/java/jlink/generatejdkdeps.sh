#!/bin/bash

function generatejdkdeps() {
  echo "Generating JDK deps"
  $JAVA_HOME/bin/java --list-modules > $S2I_JLINK_TEMP_PATH/java-modules.txt
  < $S2I_JLINK_TEMP_PATH/java-modules.txt sed "s/\\@.*//" > $S2I_JLINK_TEMP_PATH/modules.txt
  grep -Fx -f $S2I_JLINK_TEMP_PATH/stripped-deps.txt $S2I_JLINK_TEMP_PATH/modules.txt | tr '\n' ',' | tr -d "[:space:]" > $S2I_JLINK_TEMP_PATH/module-deps.txt
  echo "jdk.zipfs" >> $S2I_JLINK_TEMP_PATH/module-deps.txt
}