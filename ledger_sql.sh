#!/bin/bash

if [[ "$#" -ne 2 ]]
then
    echo "Illegal number of parameters."
    echo "Usage: /path/to/ledger_sql.sh </path/to/ledger> </path/to/scratch/dir>"
    exit
fi

LEDGER_FILE="$1"
SCRATCH_DIR="$2"
CALCITE_LEDGER_SCHEMA_NAME=LEDGER
CALCITE_LEDGER_SCHEMA_DIR="$SCRATCH_DIR/LEDGER"

clean_up () {
    ARG=$?
    rm -rf $SCRATCH_DIR
    exit $ARG
}
trap clean_up EXIT

# Initialize Calcite.
git submodule update --init --recursive

ROOT_DIR="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

pushd $ROOT_DIR/calcite && ./gradlew -q :example:csv:buildSqllineClasspath && popd >/dev/null 2>&1

mkdir -p $SCRATCH_DIR

# Populate model.json from template
sed "s/<calcite_ledger_schema_name>/$CALCITE_LEDGER_SCHEMA_NAME/g" $ROOT_DIR/model.json > "$SCRATCH_DIR/model.json"

# Use # as separator in sed instead of / to avoid confusion with / in the path.
sed -i "s#<calcite_ledger_schema_dir>#$CALCITE_LEDGER_SCHEMA_DIR#g" "$SCRATCH_DIR/model.json"

mkdir -p $CALCITE_LEDGER_SCHEMA_DIR

# Generate the CSV output of the ledger file.
$ROOT_DIR/txn_gen.sh $LEDGER_FILE $CALCITE_LEDGER_SCHEMA_DIR/LEDGER.csv "$SCRATCH_DIR/scratchfile"

# Start sqlline.
java \
  -Djavax.xml.parsers.DocumentBuilderFactory=com.sun.org.apache.xerces.internal.jaxp.DocumentBuilderFactoryImpl \
  -jar $ROOT_DIR/calcite/example/csv/build/libs/sqllineClasspath.jar \
  -u jdbc:calcite:model=$SCRATCH_DIR/model.json \
  -n admin \
  -p admin
