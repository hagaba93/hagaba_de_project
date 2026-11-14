from pyspark.sql import SparkSession
from pathlib import Path

# Initialize Spark
spark = (
    SparkSession.builder
    .appName("NOAA Weather Data Exploration")
    .master("local[2]")
    .getOrCreate()
)

# Find CSV files in the project directory
data_dir = Path(__file__).resolve().parent
csv_files = sorted(data_dir.glob("*.csv"))

print("CSV files found:")
for file in csv_files:
    print(file.name)

# Read each CSV into a separate DataFrame
for file in csv_files:
    df = (
        spark.read
        .option("header", "true")
        .option("inferSchema", "true")
        .csv(str(file))
    )

    print(f"\nDataset: {file.name}")

    # Display column names
    print("Columns:", df.columns)

    # Display column names and data types
    print("Data types:", df.dtypes)

    # Display full schema
    df.printSchema()

    # Preview first 5 rows
    df.show(5, truncate=False)

spark.stop()