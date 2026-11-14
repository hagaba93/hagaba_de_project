#!/bin/bash

# Activate Python virtual environment
source .venv/bin/activate

# Configure Java 17
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
export PATH="$JAVA_HOME/bin:$PATH"

# Verify versions
echo "Python: $(python --version)"
echo "Java: $(java -version 2>&1 | head -n 1)"
echo "JAVA_HOME: $JAVA_HOME"