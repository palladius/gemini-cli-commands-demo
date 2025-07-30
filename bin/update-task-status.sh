#!/usr/bin/env bash

find .gemini/agents/tasks/ -type f -name \*.json | while read file; do
  STATUS=$(jq -r '.status' "$file")
  if [ "$STATUS" == "running" ]; then
    TASK_ID=$(jq -r '.taskId' "$file")
    if [ -f ".gemini/agents/tasks/$TASK_ID.done" ]; then
      jq 'del(.pid) | .status = "completed"' "$file" > "$file.tmp" && mv "$file.tmp" "$file"
      echo "Updated task $TASK_ID to completed."
    fi
  fi
done
