#!/bin/bash
set -e

if [ "$1" == '/var/lib/teamcity-agent/bin/agent.sh' ]; then
export
        cat > /var/lib/teamcity-agent/conf/buildAgent.properties <<EOF
serverUrl=$TEAMCITY_SERVER_URL
name=$TEAMCITY_AGENT_NAME
workDir=../work
tempDir=../temp
systemDir=../system
ownPort=$TEAMCITY_AGENT_PORT
authorizationToken=$TEAMCITY_AGENT_TOKEN
env.HOME=/var/lib/teamcity-agent
EOF
	chown -R teamcity-agent /var/lib/teamcity-agent
	set -- gosu teamcity-agent "$@"
fi

exec "$@"
