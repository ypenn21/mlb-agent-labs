# MLB-AI-Agent-ADK

## Getting Started

mlb_scout created using adk cli
```bash
adk create \
  --model gemini-2.5-flash \
  --project $PROJECT_ID \
  --region global \
  mlb_scout
```

To get the MLB Analytics Agent up and running, follow these steps:

### 1. Setup Virtual Environment and Install Dependencies

First, activate the provided virtual environment and install the necessary Python dependencies:

```bash
python3 -m venv .venv
source .venv/bin/activate  # On macOS/Linux
# .venv\Scripts\activate   # On Windows
./create_activate_script.sh
source activate.sh
pip install -r requirements.txt
```

### 2. Start the ADK Web UI

The ADK Web UI provides an interactive interface for testing and debugging your agent. To start it:

```bash
adk web
```

This will typically launch the UI at `http://localhost:8000`.

### 3. Run the MLB Analytics Agent

To run the MLB Analytics Agent, execute the `agent.py` file:

```bash
python -m mlb_scout.agent
```

### 4. Deploy the MLB Analytics Agent

```bash
adk deploy cloud_run \
  --project $PROJECT_ID \
  --region $LOCATION \
  --service_name mlb-scout-agent \
  --with_ui \
  mlb_scout
```

---

## Troubleshooting Authentication Issues

If you encounter `invalid_grant: Bad Request` errors when running `adk web` or interacting with the agent, try these solutions:

### Quick Fix (Most Common)

Re-authenticate your Application Default Credentials:

```bash
gcloud auth application-default login
```

This will open a browser window to re-authenticate and typically resolves most `invalid_grant` errors.

### Additional Solutions

#### 1. Verify Environment Variables

Ensure your location is set correctly:

```bash
export GOOGLE_CLOUD_LOCATION=us-central1
```

Then restart `adk web`.

#### 2. Clear Cached Credentials

Remove corrupted cached credentials and re-authenticate:

```bash
# Remove cached credentials
rm -rf ~/.config/gcloud/application_default_credentials.json

# Re-authenticate
gcloud auth application-default login
```

#### 3. Enable Required APIs

Ensure necessary Google Cloud APIs are enabled:

```bash
gcloud services enable aiplatform.googleapis.com --project=$PROJECT_ID
gcloud services enable cloudaicompanion.googleapis.com --project=$PROJECT_ID
```

#### 4. Verify IAM Permissions

Your account needs these roles:
- `roles/aiplatform.user`
- `roles/serviceusage.serviceUsageConsumer`

Check your permissions:

```bash
gcloud projects get-iam-policy $PROJECT_ID --flatten="bindings[].members" --filter="bindings.members:$(gcloud config get-value account)"
```

#### 5. Check System Time

Ensure your system clock is synchronized (OAuth tokens are time-sensitive):

```bash
# On macOS
sudo sntp -sS time.apple.com

# On Linux
sudo ntpdate -s time.nist.gov
```

---

  ## Project Structure & Setup
  This project is a Python-based AI agent application utilizing the Google Agent Development Kit (ADK). It is structured to run in a specific environment
  connecting to Google Cloud Vertex AI.

   * Dependencies (`requirements.txt`): The project relies on google-adk (version 1.17.0) as the core framework and google-cloud-aiplatform for interacting with
     Gemini models on Vertex AI.
   * Environment Configuration (`activate.sh`): This script is critical. It exports necessary environment variables:
       * PROJECT_ID (genai-apps-25) & LOCATION (us-central1): Target Google Cloud environment.
       * It also activates a local virtual environment located at ~/mlb-agents/.venv.
   * Entry Point: The logic resides in the mlb_scout/ directory, which follows a standard Python package structure.

  ## mlb_scout Agent Functionality
  The core intelligence is defined in mlb_scout/agent.py. This file instantiates the root_agent using the google.adk.agents.Agent class.

   * Personality & Persona: The agent is designed as an "Enthusiastic MLB Analytics AI." The system instructions explicitly define its traits: enthusiastic ⚾,
     knowledgeable, accessible, and fun.
   * Capabilities:
       1. Built-in Knowledge: Handles questions about rules, history, and general facts without external tools.
       2. Live Data: Uses the `google_search` tool (imported from google.adk.tools) to fetch current stats, standings, and rosters.
   * Logic: The agent is instructed to distinguish between static knowledge (rules) and dynamic queries (scores), ensuring it only calls the search tool when
     necessary. It is also hardcoded to use the gemini-2.5-flash model.