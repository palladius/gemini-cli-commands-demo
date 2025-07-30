#!/usr/bin/env bash

# Get all task files, sorted by creation time (oldest first)
TASK_FILES=$(ls -tr .gemini/agents/tasks/*.json)

for current_file in $TASK_FILES; do
  CURRENT_TASK_ID=$(jq -r '.taskId' "$current_file")
  CURRENT_STATUS=$(jq -r '.status' "$current_file")
  CURRENT_AGENT=$(jq -r '.agent' "$current_file")
  CURRENT_PROMPT=$(jq -r '.prompt' "$current_file")

  # Only process pending tasks for potential duplication
  if [[ "$CURRENT_STATUS" == "pending" ]]; then
    EARLIEST_MATCHING_TASK_ID=""

    for compare_file in $TASK_FILES; do
      COMPARE_TASK_ID=$(jq -r '.taskId' "$compare_file")
      COMPARE_AGENT=$(jq -r '.agent' "$compare_file")
      COMPARE_PROMPT=$(jq -r '.prompt' "$compare_file")

      # If the current file is the same as the compare file, skip
      if [[ "$current_file" == "$compare_file" ]]; then
        continue
      fi

      # Check for matching agent and prompt
      if [[ "$COMPARE_AGENT" == "$CURRENT_AGENT" && "$COMPARE_PROMPT" == "$CURRENT_PROMPT" ]]; then
        # If we found an earlier matching task, store its ID
        if [[ -z "$EARLIEST_MATCHING_TASK_ID" || "$COMPARE_TASK_ID" < "$EARLIEST_MATCHING_TASK_ID" ]]; then
          EARLIEST_MATCHING_TASK_ID="$COMPARE_TASK_ID"
        fi
      fi
    done

    # If an earlier matching task was found, mark the current task as a duplicate
    if [[ -n "$EARLIEST_MATCHING_TASK_ID" ]]; then
      echo "Marking task $CURRENT_TASK_ID as DUPE of $EARLIEST_MATCHING_TASK_ID"
      jq 'del(.pid) | .status = "duplicate" | .duplicateOf = "'$EARLIEST_MATCHING_TASK_ID'"' "$current_file" > "$current_file.tmp" && mv "$current_file.tmp" "$current_file"
    fi
  fi
done
