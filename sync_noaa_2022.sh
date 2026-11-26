#!/usr/bin/env bash
set -euo pipefail

# Configuration
YEAR=2024
SOURCE_BUCKET="noaa-gsod-pds"
DEST_BUCKET="weazdataeng20"
TEMP_DIR="/tmp/noaa-weather/$YEAR"

echo "Starting NOAA transfer for $YEAR"

# Create temporary directory
mkdir -p "$TEMP_DIR"

# Download NOAA data anonymously
echo "Downloading NOAA $YEAR data..."

aws s3 sync \
  "s3://$SOURCE_BUCKET/$YEAR/" \
  "$TEMP_DIR/" \
  --no-sign-request \
  --only-show-errors

# Upload data using personal AWS credentials
echo "Uploading NOAA $YEAR data to S3..."

aws s3 sync \
  "$TEMP_DIR/" \
  "s3://$DEST_BUCKET/noaa-gsod/$YEAR/reload_v1/" \
  --only-show-errors

echo "Upload completed successfully!"

# Remove temporary downloaded files
rm -rf "$TEMP_DIR"

echo "Transfer finished for $YEAR"
