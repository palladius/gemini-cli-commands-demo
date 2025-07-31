
RICC_PROMPT := "in a riccardo/ folder, " + \
    "use ruby/bash (nicely designed) to build an app that looks at " + \
    "~/.gemini/ and shows Tasks, Agents, and Extensions, " + \
    "documents everything in a nice README.md and USER_MANUAL.md," + \
    "and checks for possible bugs in the .gemini/ Extensions and prompt code" + \
    "and proposes fixes. Use a PR to submit the changes to the code once sure" + \
    "and sign yourself '-- Yours, Agentic Datta-style Gemini CLI agent on behalf of Riccardo' - in the commit message."

list:
    just -l

# See if I can achieve this with BASH and JQ
list-agents-and-stuff:
    bin/list-agents.sh

run:
    gemini /agents:run

# This is a cheap Agentspace agent :)
ricc-fun:
    gemini /agents:run --agent pace

# Directly from Paul Datta
sample-task-paul:
    gemini /agents:start coder-agent "in a pauldatta/ folder, use html/css/js (nicely designed) to build an app that looks at github.com/pauldatta and is a one-stop view of the repos and what they have been built for (public repos)"

sample-task-ricc:
    gemini /agents:start coder-agent "{{RICC_PROMPT}}"
