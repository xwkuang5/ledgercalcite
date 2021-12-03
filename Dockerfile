FROM alpine

# Install Java 11.
RUN apk add openjdk11

# Add the edge and testing repositories.
RUN echo "http://nl.alpinelinux.org/alpine/edge/main" >> /etc/apk/repositories && \
     echo "http://nl.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories && \
     apk update && apk upgrade
# Install ledger and dependencies.
RUN apk add ledger

# Install bash for running scripts.
RUN apk add --upgrade bash

COPY calcite /home/ledgercalcite/calcite
WORKDIR /home/ledgercalcite/calcite
# Build sqlline
RUN ./gradlew -q :example:csv:buildSqllineClasspath

COPY txn_gen.sh /home/ledgercalcite/
COPY ledger_sql_for_docker.sh /home/ledgercalcite/
COPY example_journal /home/ledgercalcite/
COPY model.json /home/ledgercalcite/

WORKDIR /home/ledgercalcite

# Use docker run -it ledgercalcite /home/ledgercalcite/ledger_sql_for_docker.sh /tmp/scratch example_journal