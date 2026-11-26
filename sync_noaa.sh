
#!/usr/bin/env bash
set -euo pipefail

# Configuration
SOURCE_BUCKET="noaa-gsod-pds"
DEST_BUCKET="weazdataeng20"
DEST_PREFIX="noaa-gsod"
TEMP_DIR="/tmp/noaa-weather"

# Years to transfer (change as needed)
START_YEAR=2020
END_YEAR=2021

# Verify AWS credentials
echo "Checking AWS credentials..."
aws sts get-caller-identity

mkdir -p "$TEMP_DIR"

for YEAR in $(seq "$START_YEAR" "$END_YEAR"); do
    echo "===================================="
    echo "Processing year: $YEAR"
    echo "===================================="

    YEAR_DIR="$TEMP_DIR/$YEAR"
    mkdir -p "$YEAR_DIR"

    echo "Downloading NOAA data anonymously..."

    aws s3 sync \
        "s3://$SOURCE_BUCKET/$YEAR/" \
        "$YEAR_DIR/" \
        --no-sign-request \
        --only-show-errors

    echo "Uploading year $YEAR to personal S3..."

    aws s3 sync \
        "$YEAR_DIR/" \
        "s3://$DEST_BUCKET/$DEST_PREFIX/$YEAR/" \
        --only-show-errors

    echo "Upload completed for $YEAR"

    # Remove local files only after successful upload
    rm -rf "$YEAR_DIR"

    echo "Temporary files cleaned for $YEAR"
done

echo "===================================="
echo "All requested years transferred!"
echo "Destination: s3://$DEST_BUCKET/$DEST_PREFIX/"
echo "===================================="
