FROM alpine:3.20

RUN echo "DockHosting builder test"

EXPOSE 3000

CMD ["sh", "-c", "while true; do sleep 3600; done"]
