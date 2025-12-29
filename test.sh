#!/bin/bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
IMAGE_NAME="indicxlit-test"
CONTAINER_NAME="indicxlit-test-container"
PORT=4321
WAIT_TIME=30

echo -e "${YELLOW}========================================${NC}"
echo -e "${YELLOW}IndicXlit Docker Test Script${NC}"
echo -e "${YELLOW}========================================${NC}"

# Cleanup function
cleanup() {
    echo -e "\n${YELLOW}Cleaning up...${NC}"
    docker stop "$CONTAINER_NAME" 2>/dev/null || true
    docker rm "$CONTAINER_NAME" 2>/dev/null || true
}

# Set trap to cleanup on exit
trap cleanup EXIT

# Step 1: Build the Docker image
echo -e "\n${YELLOW}[1/5] Building Docker image...${NC}"
docker build -t "$IMAGE_NAME" .
echo -e "${GREEN}✓ Build successful${NC}"

# Step 2: Start the container
echo -e "\n${YELLOW}[2/5] Starting container...${NC}"
docker run -d -p "$PORT:$PORT" --name "$CONTAINER_NAME" "$IMAGE_NAME"
echo -e "${GREEN}✓ Container started${NC}"

# Step 3: Wait for the service to be ready
echo -e "\n${YELLOW}[3/5] Waiting for service to be ready...${NC}"
for i in $(seq 1 $WAIT_TIME); do
    if curl -s http://localhost:$PORT/ > /dev/null 2>&1; then
        echo -e "${GREEN}✓ Service is ready${NC}"
        break
    fi
    if [ $i -eq $WAIT_TIME ]; then
        echo -e "${RED}✗ Service failed to start within ${WAIT_TIME} seconds${NC}"
        echo -e "\n${YELLOW}Container logs:${NC}"
        docker logs "$CONTAINER_NAME"
        exit 1
    fi
    echo -n "."
    sleep 1
done

# Step 4: Test the API
echo -e "\n${YELLOW}[4/5] Testing transliteration API...${NC}"

# Test 1: English to Hindi
echo -e "\nTest 1: English to Hindi (namaste)"
RESPONSE=$(curl -s -X POST http://localhost:$PORT/transliterate \
    -H "Content-Type: application/json" \
    -d '{"input": "namaste", "source": "en", "target": "hi"}')
echo "Response: $RESPONSE"

if echo "$RESPONSE" | grep -q "नमस्ते"; then
    echo -e "${GREEN}✓ Test 1 passed${NC}"
else
    echo -e "${RED}✗ Test 1 failed${NC}"
    exit 1
fi

# Test 2: English to Tamil
echo -e "\nTest 2: English to Tamil (vanakkam)"
RESPONSE=$(curl -s -X POST http://localhost:$PORT/transliterate \
    -H "Content-Type: application/json" \
    -d '{"input": "vanakkam", "source": "en", "target": "ta"}')
echo "Response: $RESPONSE"

if echo "$RESPONSE" | grep -q "வணக்கம்"; then
    echo -e "${GREEN}✓ Test 2 passed${NC}"
else
    echo -e "${RED}✗ Test 2 failed${NC}"
    exit 1
fi

# Test 3: English to Bengali
echo -e "\nTest 3: English to Bengali (nomoshkar)"
RESPONSE=$(curl -s -X POST http://localhost:$PORT/transliterate \
    -H "Content-Type: application/json" \
    -d '{"input": "nomoshkar", "source": "en", "target": "bn"}')
echo "Response: $RESPONSE"

if echo "$RESPONSE" | grep -q "success"; then
    echo -e "${GREEN}✓ Test 3 passed${NC}"
else
    echo -e "${RED}✗ Test 3 failed${NC}"
    exit 1
fi

# Step 5: Display container stats
echo -e "\n${YELLOW}[5/5] Container stats:${NC}"
docker stats "$CONTAINER_NAME" --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}"

# Success message
echo -e "\n${GREEN}========================================${NC}"
echo -e "${GREEN}All tests passed successfully! ✓${NC}"
echo -e "${GREEN}========================================${NC}"

echo -e "\n${YELLOW}Container is running at: http://localhost:$PORT${NC}"
echo -e "${YELLOW}To view logs: docker logs $CONTAINER_NAME${NC}"
echo -e "${YELLOW}To stop: docker stop $CONTAINER_NAME${NC}"
echo -e "${YELLOW}To remove: docker rm $CONTAINER_NAME${NC}"

# Ask if user wants to keep the container running
echo -e "\n${YELLOW}Keep container running? [y/N]${NC}"
read -t 10 -n 1 -r REPLY || REPLY="n"
echo

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    cleanup
    echo -e "${GREEN}Cleanup complete${NC}"
else
    # Disable cleanup trap if keeping container
    trap - EXIT
    echo -e "${GREEN}Container kept running${NC}"
fi
