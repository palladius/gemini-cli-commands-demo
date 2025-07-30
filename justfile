
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
