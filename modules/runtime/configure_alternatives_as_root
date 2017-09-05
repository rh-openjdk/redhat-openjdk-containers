set -e

# ensure the right Java is set in the alternatives system
# Workaround for  https://issues.jboss.org/browse/CLOUD-46

JDK_DIR="/usr/lib/jvm/java-1.8.0-openjdk"
JRE_DIR="$JDK_DIR/jre"
BIN_DIR="/usr/bin"

set_java_alternatives() {
    alternatives --install $BIN_DIR/java java $JRE_DIR/bin/java 1 \
                 --slave  $BIN_DIR/jjs jjs $JRE_DIR/bin/jjs \
                 --slave  $BIN_DIR/keytool keytool $JRE_DIR/bin/keytool \
                 --slave  $BIN_DIR/orbd orbd $JRE_DIR/bin/orbd \
                 --slave  $BIN_DIR/pack200 pack200 $JRE_DIR/bin/pack200 \
                 --slave  $BIN_DIR/policytool policytool $JRE_DIR/bin/policytool \
                 --slave  $BIN_DIR/rmid rmid $JRE_DIR/bin/rmid \
                 --slave  $BIN_DIR/rmiregistry rmiregistry $JRE_DIR/bin/rmiregistry \
                 --slave  $BIN_DIR/servertool servertool $JRE_DIR/bin/servertool \
                 --slave  $BIN_DIR/tnameserv tnameserv $JRE_DIR/bin/tnameserv \
                 --slave  $BIN_DIR/policytool policytool $JRE_DIR/bin/policytool \
                 --slave  $BIN_DIR/unpack200 unpack200 $JRE_DIR/bin/unpack200

    alternatives --install $BIN_DIR/javac javac $JDK_DIR/bin/javac 1 \
                 --slave  $BIN_DIR/appletviewer appletviewer $JDK_DIR/bin/appletviewer \
                 --slave  $BIN_DIR/extcheck extcheck $JDK_DIR/bin/extcheck \
                 --slave  $BIN_DIR/idlj idlj $JDK_DIR/bin/idlj \
                 --slave  $BIN_DIR/jar jar $JDK_DIR/bin/jar \
                 --slave  $BIN_DIR/jarsigner jarsigner $JDK_DIR/bin/jarsigner \
                 --slave  $BIN_DIR/javadoc javadoc $JDK_DIR/bin/javadoc \
                 --slave  $BIN_DIR/javah javah $JDK_DIR/bin/javah \
                 --slave  $BIN_DIR/javap javap $JDK_DIR/bin/javap \
                 --slave  $BIN_DIR/jcmd jcmd $JDK_DIR/bin/jcmd \
                 --slave  $BIN_DIR/jconsole jconsole $JDK_DIR/bin/jconsole \
                 --slave  $BIN_DIR/jdb jdb $JDK_DIR/bin/jdb \
                 --slave  $BIN_DIR/jdeps jdeps $JDK_DIR/bin/jdeps \
                 --slave  $BIN_DIR/jhat jhat $JDK_DIR/bin/jhat \
                 --slave  $BIN_DIR/jinfo jinfo $JDK_DIR/bin/jinfo \
                 --slave  $BIN_DIR/jmap jmap $JDK_DIR/bin/jmap \
                 --slave  $BIN_DIR/jps jps $JDK_DIR/bin/jps \
                 --slave  $BIN_DIR/jrunscript jrunscript $JDK_DIR/bin/jrunscript \
                 --slave  $BIN_DIR/jsadebugd jsadebugd $JDK_DIR/bin/jsadebugd \
                 --slave  $BIN_DIR/jstack jstack $JDK_DIR/bin/jstack \
                 --slave  $BIN_DIR/jstat jstat $JDK_DIR/bin/jstat \
                 --slave  $BIN_DIR/jstatd jstatd $JDK_DIR/bin/jstatd \
                 --slave  $BIN_DIR/native2ascii native2ascii $JDK_DIR/bin/native2ascii \
                 --slave  $BIN_DIR/rmic rmic $JDK_DIR/bin/rmic \
                 --slave  $BIN_DIR/schemagen schemagen $JDK_DIR/bin/schemagen \
                 --slave  $BIN_DIR/serialver serialver $JDK_DIR/bin/serialver \
                 --slave  $BIN_DIR/wsgen wsgen $JDK_DIR/bin/wsgen \
                 --slave  $BIN_DIR/wsimport wsimport $JDK_DIR/bin/wsimport \
                 --slave  $BIN_DIR/xjc xjc $JDK_DIR/bin/xjc

    alternatives --set java $JRE_DIR/bin/java
    alternatives --set javac $JDK_DIR/bin/javac
}

set_java_alternatives
