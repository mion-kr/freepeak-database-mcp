FROM freepeak/db-mcp-server:latest

RUN apk add --no-cache bash gettext

WORKDIR /app

COPY config/mcp-config.template.json /app/config.template.json
COPY scripts/render-config-entrypoint.sh /usr/local/bin/render-config-entrypoint.sh

RUN chmod +x /usr/local/bin/render-config-entrypoint.sh

ENV CONFIG_TEMPLATE_PATH=/app/config.template.json

ENTRYPOINT ["/usr/local/bin/render-config-entrypoint.sh"]
CMD ["/bin/bash","-c","/app/server -t ${TRANSPORT_MODE} -p ${SERVER_PORT} -c ${CONFIG_PATH}"]
