#!/bin/sh

PATH=$PATH:$HOME/.local/bin:$HOME/bin

export JAVA_HOME=/opt/jdk1.8.0_91
export PATH=$JAVA_HOME/bin:$PATH 
export CLASSPATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar 

export MAVEN_HOME=/opt/apache-maven-3.3.3
export PATH=$MAVEN_HOME/bin:$PATH

export PATH

java -jar /opt/jrebel.jar -set-remote-password 12345678

/opt/apache-tomcat-8.0.33/bin/startup.sh

sleep 10s

tail -100f /opt/apache-tomcat-8.0.33/logs/catalina.out 
