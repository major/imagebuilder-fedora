#!/bin/bash
set -euo pipefail

CONTAINER_NAME=imagebuilder
IMAGE_UUID=$(uuidgen)
SHIP_TO_AWS=yes

podman-exec () {
    sudo podman exec -t $CONTAINER_NAME $@
}

composer-cli () {
    podman-exec composer-cli $@
}

# Start the container.
echo "🚀 Launching the container"
sudo podman run --rm --detach --privileged \
    -v $(pwd)/shared:/repo \
    --name $CONTAINER_NAME \
    $CONTAINER

# Wait for composer to be fully running.
echo "⏱ Waiting for composer to start"
for i in `seq 1 10`; do
    sleep 1
    composer-cli status show && break
done

echo "📥 Pushing the blueprint"
composer-cli blueprints push /repo/${BLUEPRINT_NAME}.toml

echo "🛠 Build the image"
composer-cli --json compose start ${BLUEPRINT_NAME} image-installer | tee compose_start.json

COMPOSE_ID=$(jq -r ".[0].body.build_id" compose_start.json)

# Watch the logs while the build runs.
podman-exec journalctl -af &

# Sometimes osbuild-composer gets a bit grumpy if we check for status immediately and we
# end up with JSON that is partially built. We wait just a moment before checking it.
sleep 10

COUNTER=0
while true; do
    composer-cli --json compose info "${COMPOSE_ID}" | tee compose_info.json
    COMPOSE_STATUS=$(jq -r ".[0].body.queue_status" compose_info.json)

    # Print a status line once per minute.
    if [ $((COUNTER%60)) -eq 0 ]; then
        echo "💤 Waiting for the compose to finish at $(date +%H:%M:%S)"
    fi

    # Is the compose finished?
    if [[ $COMPOSE_STATUS != RUNNING ]] && [[ $COMPOSE_STATUS != WAITING ]]; then
        echo "🎉 Compose finished."
        break
    fi
    sleep 15

    let COUNTER=COUNTER+1
done

if [[ $COMPOSE_STATUS != FINISHED ]]; then
    composer-cli compose logs ${COMPOSE_ID}
    podman-exec tar -axf /${COMPOSE_ID}-logs.tar logs/osbuild.log -O
    echo "😢 Something went wrong with the compose"
    exit 1
fi
