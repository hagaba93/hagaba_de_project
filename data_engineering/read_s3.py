from pyspark.sql import SparkSession

spark = (
    SparkSession.builder
    .appName("S3WeatherData")
    .master("local[2]")
    .config(
        "spark.jars.packages",
        "org.apache.hadoop:hadoop-aws:3.3.4"
    ).config(
        "spark.hadoop.fs.s3a.aws.credentials.provider",
        "com.amazonaws.auth.DefaultAWSCredentialsProviderChain"
    )
    .getOrCreate()
)

# S3 location
s3_path = "s3a://agabweatherdataset/noaa-gsod/"

# Read CSV files from all year folders
df = (
    spark.read
    .option("header", "true")
    .option("inferSchema", "true")
    .option("recursiveFileLookup", "true")
    .csv(s3_path)
)

# Display the schema
df.printSchema()

# Display all column names
print("Columns:", df.columns)

# Display column names and data types
print("Column types:", df.dtypes)

# Preview the data
df.show(10, truncate=False)

spark.stop()