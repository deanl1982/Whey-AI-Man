from azure.ai.projects import AIProjectClient
from azure.identity import DefaultAzureCredential
from azure.ai.agents.models import ListSortOrder
import os

# Get configuration from environment variables or use defaults
endpoint = os.getenv("AZURE_AI_PROJECT_ENDPOINT", "https://hob-aif.services.ai.azure.com/api/projects/hob-aif")
agent_id = os.getenv("AZURE_AI_AGENT_ID", "asst_mGBvg6aKolp9lUtH6IytS1o7")

# Initialize credentials
try:
    credential = DefaultAzureCredential(exclude_interactive_browser_credential=False)
except Exception as e:
    print(f"Error initializing credentials: {e}")
    raise

# Create project client
try:
    project = AIProjectClient(
        credential=credential,
        endpoint=endpoint)
    print(f"Connected to Azure AI Project at {endpoint}")
except Exception as e:
    print(f"Error connecting to Azure AI Project: {e}")
    print(f"Endpoint: {endpoint}")
    raise

# Get agent
try:
    agent = project.agents.get_agent(agent_id)
    print(f"Retrieved agent: {agent.id}")
except Exception as e:
    print(f"Error retrieving agent {agent_id}: {e}")
    raise

# Create thread
try:
    thread = project.agents.threads.create()
    print(f"Created thread, ID: {thread.id}")
except Exception as e:
    print(f"Error creating thread: {e}")
    raise

# Send message
try:
    message = project.agents.messages.create(
        thread_id=thread.id,
        role="user",
        content="""
                    ApplicationName: "PulseCheck Portal"
                    AppVendor: "MediCore Systems"
                    AppVersion: "2.4.1"
                    RequestedEntraPermissions: ["User.Read.All (Application)", "Directory.Read.All (Application)"]
                    DataStorageLocation: "UK"
"""
    )
    print(f"Sent message: {message.id}")
except Exception as e:
    print(f"Error sending message: {e}")
    raise

# Run agent
try:
    run = project.agents.runs.create_and_process(
        thread_id=thread.id,
        agent_id=agent.id)
    print(f"Run completed with status: {run.status}")
except Exception as e:
    print(f"Error running agent: {e}")
    raise

# Process results
if run.status == "failed":
    print(f"Run failed: {run.last_error}")
else:
    try:
        messages = project.agents.messages.list(thread_id=thread.id, order=ListSortOrder.ASCENDING)
        print("\n--- Conversation ---")
        for message in messages:
            if message.text_messages:
                print(f"{message.role}: {message.text_messages[-1].text.value}")
    except Exception as e:
        print(f"Error retrieving messages: {e}")
        raise