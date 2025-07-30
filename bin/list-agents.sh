#!/usr/bin/env bash

printf "%-10s %-10s %-15s %-5s %-5s %-s\n" "PID" "STATUS" "AGENT" "LOG" "PLAN" "PROMPT"
echo "====================================================================================================="

find .gemini/agents/tasks/ -type f -name \*.json | while read file; do
  PID=$(jq -r '.pid // "-"' "$file")
  STATUS=$(jq -r '.status' "$file")
  AGENT=$(jq -r '.agent' "$file")
  PROMPT=$(jq -r '.prompt' "$file")
  LOG_FILE=$(jq -r '.logFile // ""' "$file")
  PLAN_FILE=$(jq -r '.planFile // ""' "$file")

  LOG_INDICATOR="✗"
  if [ -f "$LOG_FILE" ]; then
    LOG_INDICATOR="✓"
    if grep -qE "(Error|failed|Quota exceeded)" "$LOG_FILE"; then
      LOG_INDICATOR="Err"
    fi
  fi

  PLAN_INDICATOR="✗"
  if [ -f "$PLAN_FILE" ]; then
    PLAN_INDICATOR="✓"
  fi

  # Format prompt into two lines
  PROMPT_LINE1=$(echo "$PROMPT" | cut -c 1-40)
  if [ ${#PROMPT} -gt 40 ]; then
    PROMPT_LINE1="${PROMPT_LINE1}..."
  fi
  PROMPT_LINE2=$(echo "$PROMPT" | cut -c 41-80)
  if [ ${#PROMPT} -gt 80 ]; then
    PROMPT_LINE2="${PROMPT_LINE2}..."
  fi

  printf "%-10s %-10s %-15s %-5s %-5s %-s\n" "$PID" "$STATUS" "$AGENT" "$LOG_INDICATOR" "$PLAN_INDICATOR" "$PROMPT_LINE1"
  printf "%-10s %-10s %-15s %-5s %-5s %-s\n" "" "" "" "" "" "$PROMPT_LINE2"
done
