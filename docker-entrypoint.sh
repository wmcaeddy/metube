#!/bin/sh

echo "Setting umask to ${UMASK}"
umask ${UMASK}
echo "Creating download directory (${DOWNLOAD_DIR}), state directory (${STATE_DIR}), and temp dir (${TEMP_DIR})"
mkdir -p "${DOWNLOAD_DIR}" "${STATE_DIR}" "${TEMP_DIR}"

# Copy ytdl-options.json if it exists
if [ -f "/app/ytdl-options.json" ]; then
    echo "Found ytdl-options.json, setting YTDL_OPTIONS_FILE"
    export YTDL_OPTIONS_FILE="/app/ytdl-options.json"
else
    echo "No ytdl-options.json found, using default configuration"
fi

if [ `id -u` -eq 0 ] && [ `id -g` -eq 0 ]; then
    if [ "${UID}" -eq 0 ]; then
        echo "Warning: it is not recommended to run as root user, please check your setting of the UID environment variable"
    fi
    echo "Changing ownership of download and state directories to ${UID}:${GID}"
    chown -R "${UID}":"${GID}" /app "${DOWNLOAD_DIR}" "${STATE_DIR}" "${TEMP_DIR}"
    echo "Running MeTube as user ${UID}:${GID}"
    exec su-exec "${UID}":"${GID}" python3 app/main.py
else
    echo "User set by docker; running MeTube as `id -u`:`id -g`"
    exec python3 app/main.py
fi
