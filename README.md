# spark-cassandra

## Docker container

You can build and run the docker container with:

    host# docker build .
    host# docker -it run <container-id>

## Using the interactive spark shell

Spark provides an interactive shell that can be easily started by a script:

    root@docker# ./spark-cass
    scala> import com.datastax.spark.connector._;
    scala> val table = sc.cassandraTable("testkeyspace","trigram");
    scala> table.count
    
## Using the example sbt project

Build and run the example with:

    cd /root/trigram
    sbt assembly
    
