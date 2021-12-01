#!/bin/bash
# TODO(xwkuang5): consider switching to a python script and add unit tests.
# TODO(xwkuang5): support the notes column %(quoted(join(note | xact.note))).
# TODO(xwkuang5): make filename part of txn id.

function join_by { local d=${1-} f=${2-}; if shift 2; then printf %s "$f" "${@/#/$d}"; fi; }

if [[ "$#" -ne 3 ]]
then
    echo "Illegal number of parameters."
    echo "Usage: /path/to/txn_gen.sh <ledger> <output> <scratch>"
    exit
fi

# Check if ledger is available from the executable $PATH.
if ! command -v ledger &> /dev/null
then
    echo "ledger could not be found. Please install ledger (https://www.ledger-cli.org/download.html) and make it available from \$PATH."
    exit
fi

ledger -f $1 csv \
    --date-format '%Y-%m-%d' \
    --csv-format "%(beg_pos),%(end_pos),%(date),%(code),%(payee),%(display_account),%(commodity(scrub(display_amount))),%(quantity(scrub(display_amount))),%(cleared ? \"cleared\" : (pending ? \"pending\" : \"unknown\"))\n" \
    --output $3

# User-visible fields are date, code, payee, account, commodity, quantity
# and status.
NUM_USER_VISIBLE_FIELDS=7
USER_VISIBLE_FIELD_START_IDX=2

# Calcite header.
HEADER="TXN_ID:long,TXN_DATE:date,CODE:string,PAYEE:string,ACCOUNT:string,COMMODITY:string,QUANTITY:\"decimal(18,2)\",STATUS:string"

# Truncate the output.
: > $2
echo $HEADER >> $2
cur_txn_id=0
prev_end_pos=
while IFS= read -r line; do
    IFS=',' read -ra arr <<< "$line"
    beg_pos=${arr[0]}
    end_pos=${arr[1]}
    if [ "$prev_end_pos" != "$beg_pos" ]
    then
        cur_txn_id=$((cur_txn_id+1))
    fi
    line_out="$cur_txn_id"
    # Loop through the array and append ','. Note that some fields might be null
    # so a naive join will not work.
    cur_idx=$USER_VISIBLE_FIELD_START_IDX
    end_idx=$((USER_VISIBLE_FIELD_START_IDX+NUM_USER_VISIBLE_FIELDS))
    while [ $cur_idx -lt $end_idx ]
    do
      line_out="$line_out,${arr[cur_idx]}"
      ((cur_idx++))
    done
    echo "$line_out" >> $2
    prev_end_pos=$end_pos
done < "$3"

rm -f $3
