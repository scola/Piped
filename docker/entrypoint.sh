#!/bin/sh

if [ -z "${BACKEND_HOSTNAME}" ]; then
    echo "BACKEND_HOSTNAME not set"
    exit 1
fi

HTTP_MODE=${HTTP_MODE:-https}

# Replace the default API URL if it exists
sed -i "s@https://pipedapi.kavin.rocks@${HTTP_MODE}://${BACKEND_HOSTNAME}@g" /usr/share/nginx/html/assets/* /usr/share/nginx/html/opensearch.xml
sed -i "s/pipedapi.kavin.rocks/${BACKEND_HOSTNAME}/g" /usr/share/nginx/html/assets/* /usr/share/nginx/html/opensearch.xml

# Handle the case where VITE_PIPED_API was undefined during build (void 0)
# Replace patterns like getPreferenceString("instance",void 0) with the actual backend URL
sed -i "s@getPreferenceString(\"instance\",void 0)@getPreferenceString(\"instance\",\"${HTTP_MODE}://${BACKEND_HOSTNAME}\")@g" /usr/share/nginx/html/assets/*

if [ -n "${HTTP_WORKERS}" ]; then
    sed -i "s/worker_processes  auto;/worker_processes  ${HTTP_WORKERS};/g" /etc/nginx/nginx.conf
fi

if [ -n "${HTTP_PORT}" ]; then
    sed -i "s/80;/${HTTP_PORT};/g" /etc/nginx/conf.d/default.conf
fi

nginx -g "daemon off;"
