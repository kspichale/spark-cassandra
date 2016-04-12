FROM nimmis/java:openjdk-8-jdk
MAINTAINER kspichale

WORKDIR /usr/local
RUN echo "deb http://debian.datastax.com/community stable main"  >> /etc/apt/sources.list.d/cassandra.sources.list
RUN curl -L http://debian.datastax.com/debian/repo_key | sudo apt-key add -
# add python default scala is too old: 2.9 but we need 2.10
RUN sudo apt-add-repository -y ppa:fkrull/deadsnakes
RUN apt-get update
RUN apt-get -y install python2.7 python-support libjna-java git vim

# add scala
RUN curl -L http://www.scala-lang.org/files/archive/scala-2.10.4.tgz | tar -zx ; ln -s scala-2.10.4 scala
RUN curl -s http://d3kbcqa49mib13.cloudfront.net/spark-1.4.1.tgz| tar -xz ; ln -s spark-1.4.1 spark 

RUN cd spark/build ; rm sbt-launch-0.13.7.jar ; wget http://repo.typesafe.com/typesafe/ivy-releases/org.scala-sbt/sbt-launch/0.13.7/sbt-launch.jar ; mv sbt-launch.jar sbt-launch-0.13.7.jar

RUN cd spark ; build/sbt assembly

# install cassandra
RUN wget http://debian.datastax.com/community/pool/cassandra_2.1.9_all.deb ; dpkg -i cassandra_2.1.9_all.deb

# install and build spark-cassandra connector
RUN wget http://repo1.maven.org/maven2/com/datastax/spark/spark-cassandra-connector_2.10/1.4.0/spark-cassandra-connector_2.10-1.4.0.jar
RUN wget http://central.maven.org/maven2/joda-time/joda-time/2.8/joda-time-2.8.jar

# add cassandra-java-driver
RUN curl -L http://downloads.datastax.com/java-driver/cassandra-java-driver-2.1.5.tar.gz | tar -zx ; ln -s cassandra-java-driver-2.1.5 cassandra-java-driver

# install sbt
RUN curl -L -s https://dl.bintray.com/sbt/native-packages/sbt/0.13.7/sbt-0.13.7.tgz | tar -zx 

# cassandra host defaults to the real ip so we change it to localhost 
RUN echo spark.cassandra.connection.host 127.0.0.1 >> /usr/local/spark/conf/spark-defaults.conf
RUN echo spark.executor.extraClassPath /usr/local/spark-cassandra-connector_2.10-1.4.0.jar >> /usr/local/spark/conf/spark-defaults.conf

# cassandra service warns trying to set ulimits in a container, so disable ulimit commands
RUN perl -pi.bak -e 's/ulimit/#ulimit/g' /etc/init.d/cassandra 

# install test data
WORKDIR /root
COPY example /root/example
COPY example.sql /root/example.sql
COPY example-input /root/example-input

# start cassandra and load test db
RUN service cassandra start; sleep 15; cqlsh < example.sql 

# build a nice simple script to run spark-cassandra
RUN echo '#!/bin/bash' > spark-cass ; echo 'spark-shell --jars $(echo /usr/local/cassandra-java-driver/lib/*.jar /usr/local/cassandra-java-driver/*.jar /usr/local/joda-time-2.8.jar /usr/local/spark-cassandra-connector_2.10-1.4.0.jar /usr/share/cassandra/apache-cassandra-thrift-*.jar /usr/share/cassandra/lib/libthrift-*.jar | sed -e "s/ /,/g")' >> spark-cass ; chmod 755 spark-cass
RUN echo 'SPARKPATH=$(echo /usr/local/cassandra-java-driver/*.jar /usr/local/spark-cassandra-connector/spark-cassandra-connector/target/scala-2.10/*.jar /usr/local/spark-cassandra-connector/spark-cassandra-connector-java/target/scala-2.10/*.jar /usr/share/cassandra/apache-cassandra-thrift-*.jar /usr/share/cassandra/lib/libthrift-*.jar /usr/local/cassandra-java-driver/lib/*.jar | sed -e "s/ /:/g")' >> spark-cass-env.sh 

ENV PATH /usr/local/spark/bin:/usr/local/cassandra/bin:/usr/local/sbt/bin:/usr/local/scala/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

CMD service cassandra start && /bin/bash
