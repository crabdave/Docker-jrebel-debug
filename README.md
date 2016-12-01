# Docker-jrebel-debug

#1、准备jrebel.jar文件，生成jrebel服务端密码
	java -jar /opt/jrebel.jar -set-remote-password 12345678
 
#2、修改catalina.sh文件
	指定debug端口、jrebel热部署端口等 ，添加
	export JAVA_OPTS="-javaagent:/opt/jrebel.jar -Drebel.remoting_plugin=true -Drebel.remoting_port=8000 -agentlib:jdwp=transport=dt_socket,address=58200,suspend=n,server=y"
 
#3、修改tomcat配置
	配置支持maven cargo:deploy 远程部署war
	modify tomcat setting
	modify server.xml  for manager web page
	sed -i '/<\/Host>/i <Context path=\"/manager\" docBase=\"/opt/apache-tomcat-8.0.33/webapps/manager\" debug=\"0\" privileged=\"true\"/>' /opt/apache-tomcat-8.0.33/conf/server.xml
 
	modify tomcat-users.xml for deploy role auth
	sed -i '/<\/tomcat-users>/i \<role rolename="admin"/>' /opt/apache-tomcat-8.0.33/conf/tomcat-users.xml
	sed -i '/<\/tomcat-users>/i \<user username="admin" password="admin" roles="admin,manager-script,manager-gui"/>' /opt/apache-tomcat-8.0.33/conf/tomcat-users.xml
 
	modify web.xml for the war more than 50M
	sed -i 's/52428800/-1/g' /opt/apache-tomcat-8.0.33/webapps/manager/WEB-INF/web.xml 
 
#4、在Intellij IDEA 配置remote debug
#4.1）自动编译java文件
	Preferences->Build,Execution,Deployment->Compiler->Make project automatically
 	手动点编译（在Intellij IDEA 左上，选择 Tomcat 框的左边，向下的绿箭头图标）
#4.2）配置remote
      	Preferences->Jrebel->Remote servers
                添加Jrebel使用的地址、端口(前面设置的是8000)和密码（前面设置的是12345678），点击测试，看是否成功（tomcat启动之后才会成功）。    
 
        Run->Edit Configurations  + Remote ->
                指定 address=58200 debug调试端口
                module's classpath 指定要debug的项目
                Before launch:选择 xxx:war exploded
#4.3）Configure modules for remote server support.
        View > Tool Windows > JRebel. 
        把后面两个勾打上
#4.4） 本地用maven打包部署到远程tomcat上，
       mvn clean compile package cargo:deploy
       然后开始同步，debug

# start
       在Intellij IDEA 左上，选择 Tomcat 框（选择刚配置的remote）的右边，小虫子是Remote debug按钮,云上的绿火箭是热部署手工同步按钮。

#build docker image
	docker build -t debuger .

#generate docker container
	docker run -d -p 8080:8080 -p 8000:8000 -p 58200:58200 -e "container=container-debuger" --name container-debuger -h container-debuger debuger

#参考
https://github.com/horklim/doc/wiki/HOW-TO-REMOTELY-DEBUG-APPLICATION-RUNNING-ON-TOMCAT-FROM-WITHIN-INTELLIJ-IDEA

http://manuals.zeroturnaround.com/jrebel/remoteserver/intellij.html

http://manuals.zeroturnaround.com/jrebel/remoteserver/intellij.html#intellijremoteserver

