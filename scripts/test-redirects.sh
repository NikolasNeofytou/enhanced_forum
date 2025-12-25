#!/bin/bash
# Redirect Testing Script
# Tests that old phpBB URLs redirect correctly to Discourse

# Configuration
DISCOURSE_URL="https://staging-forum.example.com"
TEST_RESULTS_FILE="redirect_test_results_$(date +%Y%m%d_%H%M%S).txt"

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Counters
PASS=0
FAIL=0
TOTAL=0

# Initialize results file
echo "Redirect Test Results" > "$TEST_RESULTS_FILE"
echo "Generated: $(date)" >> "$TEST_RESULTS_FILE"
echo "Testing against: $DISCOURSE_URL" >> "$TEST_RESULTS_FILE"
echo "==================================" >> "$TEST_RESULTS_FILE"
echo "" >> "$TEST_RESULTS_FILE"

# Function to test redirect
test_redirect() {
    local old_url=$1
    local expected_pattern=$2
    local description=$3
    
    ((TOTAL++))
    
    # Get response
    response=$(curl -s -L -o /dev/null -w "%{http_code}|%{redirect_url}|%{url_effective}" "${DISCOURSE_URL}${old_url}")
    
    http_code=$(echo "$response" | cut -d'|' -f1)
    redirect_url=$(echo "$response" | cut -d'|' -f2)
    final_url=$(echo "$response" | cut -d'|' -f3)
    
    # Check if redirect happened
    if [[ $http_code == "301" || $http_code == "302" ]] || [[ "$final_url" != "${DISCOURSE_URL}${old_url}" ]]; then
        # Check if redirect matches expected pattern
        if [[ "$final_url" =~ $expected_pattern || "$redirect_url" =~ $expected_pattern ]]; then
            echo -e "${GREEN}✓ PASS${NC}: $description"
            echo "PASS: $description" >> "$TEST_RESULTS_FILE"
            echo "  Old URL: $old_url" >> "$TEST_RESULTS_FILE"
            echo "  New URL: $final_url" >> "$TEST_RESULTS_FILE"
            echo "" >> "$TEST_RESULTS_FILE"
            ((PASS++))
        else
            echo -e "${RED}✗ FAIL${NC}: $description"
            echo "  Expected pattern: $expected_pattern"
            echo "  Actual redirect: $final_url"
            echo "FAIL: $description" >> "$TEST_RESULTS_FILE"
            echo "  Old URL: $old_url" >> "$TEST_RESULTS_FILE"
            echo "  Expected pattern: $expected_pattern" >> "$TEST_RESULTS_FILE"
            echo "  Actual URL: $final_url" >> "$TEST_RESULTS_FILE"
            echo "  HTTP Code: $http_code" >> "$TEST_RESULTS_FILE"
            echo "" >> "$TEST_RESULTS_FILE"
            ((FAIL++))
        fi
    elif [[ $http_code == "200" && "$old_url" == "/" ]]; then
        # Index page, 200 is OK
        echo -e "${GREEN}✓ PASS${NC}: $description"
        echo "PASS: $description (HTTP 200 OK)" >> "$TEST_RESULTS_FILE"
        ((PASS++))
    else
        echo -e "${RED}✗ FAIL${NC}: $description (HTTP $http_code, no redirect)"
        echo "FAIL: $description" >> "$TEST_RESULTS_FILE"
        echo "  Old URL: $old_url" >> "$TEST_RESULTS_FILE"
        echo "  HTTP Code: $http_code" >> "$TEST_RESULTS_FILE"
        echo "  No redirect occurred" >> "$TEST_RESULTS_FILE"
        echo "" >> "$TEST_RESULTS_FILE"
        ((FAIL++))
    fi
}

echo "================================================"
echo "Testing phpBB to Discourse URL Redirects"
echo "================================================"
echo ""

# Test cases - modify these based on your actual topic/forum IDs
echo "Testing topic redirects..."
test_redirect "/viewtopic.php?t=1" "/t/" "Topic ID 1"
test_redirect "/viewtopic.php?t=10" "/t/" "Topic ID 10"
test_redirect "/viewtopic.php?t=100" "/t/" "Topic ID 100"
test_redirect "/viewtopic.php?t=1000" "/t/" "Topic ID 1000"
test_redirect "/viewtopic.php?f=5&t=100" "/t/" "Topic with forum parameter"

echo ""
echo "Testing forum/category redirects..."
test_redirect "/viewforum.php?f=1" "/c/" "Forum ID 1"
test_redirect "/viewforum.php?f=5" "/c/" "Forum ID 5"
test_redirect "/viewforum.php?f=10" "/c/" "Forum ID 10"

echo ""
echo "Testing other pages..."
test_redirect "/index.php" "/" "Index page"
test_redirect "/" "/" "Root page"
test_redirect "/search.php" "/search" "Search page"

echo ""
echo "Testing post-specific redirects..."
test_redirect "/viewtopic.php?p=100" "/t/" "Post ID 100"
test_redirect "/viewtopic.php?p=1000#p1000" "/t/" "Post ID 1000 with anchor"

echo ""
echo "================================================"
echo "Test Summary"
echo "================================================"
echo -e "Total tests: $TOTAL"
echo -e "${GREEN}Passed: $PASS${NC}"
echo -e "${RED}Failed: $FAIL${NC}"
PASS_RATE=$((PASS * 100 / TOTAL))
echo -e "Pass rate: ${PASS_RATE}%"

# Write summary to file
echo "" >> "$TEST_RESULTS_FILE"
echo "================================================" >> "$TEST_RESULTS_FILE"
echo "Summary" >> "$TEST_RESULTS_FILE"
echo "================================================" >> "$TEST_RESULTS_FILE"
echo "Total tests: $TOTAL" >> "$TEST_RESULTS_FILE"
echo "Passed: $PASS" >> "$TEST_RESULTS_FILE"
echo "Failed: $FAIL" >> "$TEST_RESULTS_FILE"
echo "Pass rate: ${PASS_RATE}%" >> "$TEST_RESULTS_FILE"

echo ""
echo "Detailed results saved to: $TEST_RESULTS_FILE"

# Exit with failure if any tests failed
if [ $FAIL -gt 0 ]; then
    exit 1
else
    exit 0
fi
