import org.apache.spark._;
import org.apache.spark.SparkContext._;

object Users {
  def main(args: Array[String]) {
    val conf = new SparkConf(true).set("spark.cassandra.connection.host", "127.0.0.1");
    import com.datastax.spark.connector._;
    val sc = new SparkContext("local","My Cluster",conf);
    val ts = sc.cassandraTable("testkeyspace","users");
    ts.select("name").where("active = ?", true).toArray.foreach(println)
  }
}
