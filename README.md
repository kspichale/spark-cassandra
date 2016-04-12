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
    
Compute 2 clusters for given vectors:

    val v1 = Vectors.dense(0.0, 0.0, 0.0)
    val v2 = Vectors.dense(0.1, 0.1, 0.1)
    val v3 = Vectors.dense(9.0, 9.0, 9.0)
    val v4 = Vectors.dense(9.1, 9.1, 9.1)

    val distVectors = sc.parallelize(Array(v1, v2, v3, v4))

    val numClusters = 2
    val numIterations = 20
    val clusters = KMeans.train(distVectors, numClusters, numIterations)

    clusters.clusterCenters.foreach { println }
    
## Using the example sbt project

Build the Scala example with:

    cd /root/example
    sbt assembly

Run the example with:

    spark-submit --class Users /root/example/target/scala-2.10/example-spark-cass-assembly-1.0.jar
