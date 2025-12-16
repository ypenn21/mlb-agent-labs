#!/bin/bash
LOCATION="us-central1"
SERVICE_URL=$(gcloud run services describe mlb-scout-agent \
    --region $LOCATION \
    --format 'value(status.url)')
echo "Agent deployed at: $SERVICE_URL"

function run_test() {
    DESC=$1
    shift
    echo "--- $DESC ---"
    
    # Capture http code and response body
    # Using a temp file for response body to handle json formatting securely
    RESPONSE_FILE=$(mktemp)
    HTTP_CODE=$(curl -s -o "$RESPONSE_FILE" -w "%{http_code}" "$@")
    
    echo "HTTP STATUS: $HTTP_CODE"
    echo "RESPONSE BODY:"
    if [ -s "$RESPONSE_FILE" ]; then
        # Try to pretty print json, fallback to cat if not valid json or python fails
        cat "$RESPONSE_FILE" | python3 -m json.tool 2>/dev/null || cat "$RESPONSE_FILE"
    else
        echo "(empty)"
    fi
    echo ""
    echo ""
    rm "$RESPONSE_FILE"
}

run_test "Initializing session" \
    -X POST "$SERVICE_URL/apps/mlb_scout/users/test_user/sessions/session_001" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $(gcloud auth print-identity-token)" \
    -d '{"state":{}}'

run_test "Querying best momentum teams" \
    -X POST "$SERVICE_URL/run" \
    -H "Content-Type: application/json" \
    -d '{
        "app_name": "mlb_scout",
        "user_id": "test_user",
        "session_id": "session_001",
        "new_message": {
            "role": "user",
            "parts": [{"text": "Which teams have the best momentum right now?"}]
        }
    }'

run_test "Predicting Dodgers vs Giants" \
    -X POST "$SERVICE_URL/run" \
    -H "Content-Type: application/json" \
    -d '{
        "app_name": "mlb_scout",
        "user_id": "test_user", 
        "session_id": "session_001",
        "new_message": {
            "role": "user",
            "parts": [{"text": "Predict Dodgers vs Giants if the Dodgers are home"}]
        }
   }'
