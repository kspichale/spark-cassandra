name := "example-spark-cass"

version := "1.0"

scalaVersion := "2.10.4"

libraryDependencies += "org.apache.spark" %% "spark-core" % "1.1.0" % "provided"

libraryDependencies += "org.apache.spark" %% "spark-sql" % "1.1.0" % "provided"

libraryDependencies += "com.datastax.spark" %% "spark-cassandra-connector" % "1.4.0" withSources() withJavadoc()

libraryDependencies += "com.datastax.spark" %% "spark-cassandra-connector-java" % "1.4.0" withSources() withJavadoc()
