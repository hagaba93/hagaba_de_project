from pyspark.sql import SparkSession

spark = (
    SparkSession.builder
    .master("local[2]")
    .appName("CheckHadoop")
    .getOrCreate()
)

hadoop_version = spark._jvm.org.apache.hadoop.util.VersionInfo.getVersion()

print("Hadoop version:", hadoop_version)

spark.stop()