#!/usr/bin/env bash

AGENT_NAME="$1"
PROMPT="$2"
CURRENT_TIMESTAMP_EPOCH=$(date -u +"%s")

FOUND_RECENT_DUPLICATE=false

if [ -z "$AGENT_NAME" ] || [ -z "$PROMPT" ]; then
  echo "Usage: $0 <agent_name> \"<prompt>\""
  exit 1
fi

find .gemini/agents/tasks/ -type f -name "*.json" | while read file; do
  TASK_AGENT=$(jq -r '.agent' "$file")
  TASK_PROMPT=$(jq -r '.prompt' "$file")
  TASK_CREATED_AT_ISO=$(jq -r '.createdAt' "$file")
  TASK_STATUS=$(jq -r '.status' "$file")

  if [[ "$TASK_AGENT" == "$AGENT_NAME" && "$TASK_PROMPT" == "$PROMPT" ]]; then
    if [[ "$TASK_STATUS" == "pending" || "$TASK_STATUS" == "running" ]]; then
      # Convert ISO 8601 to epoch for comparison
      TASK_CREATED_AT_EPOCH=$(date -j -f "%Y-%m-%dT%H:%M:%SZ" "$TASK_CREATED_AT_ISO" "+%s")
      TIME_DIFF=$(( CURRENT_TIMESTAMP_EPOCH - TASK_CREATED_AT_EPOCH ))

      if (( TIME_DIFF < 3600 && TIME_DIFF >= 0 )); then # Within 1 hour and not a future task
        echo "WARNING: A similar task already exists and was created recently (within 1 hour):"
        echo "  Task ID: $(jq -r '.taskId' "$file")"
        echo "  Status: $TASK_STATUS"
        echo "  Created At: $TASK_CREATED_AT_ISO"
        echo "  Prompt: $TASK_PROMPT"
        echo "Consider if you really need to create a new task. It might be a duplicate."
        FOUND_RECENT_DUPLICATE=true
      elif (( TIME_DIFF >= 3600 || TIME_DIFF < 0 )); then # More than 1 hour apart or future task
        echo "INFO: A similar task exists, but it was created more than 1 hour ago (or in the future):"
        echo "  Task ID: $(jq -r '.taskId' "$file")"
        echo "  Status: $TASK_STATUS"
        echo "  Created At: $TASK_CREATED_AT_ISO"
        echo "  Prompt: $TASK_PROMPT"
        echo "This might be a recurring task (e.g., cron job). Proceed with caution if you intend to create a new, distinct task."
      fi
    fi
  fi
done

if ! $FOUND_RECENT_DUPLICATE; then
  echo "No recent duplicate tasks found. You can proceed to create the new task."
fi
