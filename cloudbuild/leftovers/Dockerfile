FROM debian

RUN apt-get -y update && \
    apt-get install -y ca-certificates curl wget

RUN curl -L https://github.com/genevieve/leftovers/releases/download/v0.62.0/leftovers-v0.62.0-linux-amd64 -o /usr/local/bin/leftovers && \
    chmod +x /usr/local/bin/leftovers

ENV PATH="/usr/local/bin:/bin:${PATH}"

ENTRYPOINT ["leftovers"]
