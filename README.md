# ledgercalcite
Query ledger with SQL.

## Platform

Unix-like systems (tested on Linux)

## Usage

Please ensure that [ledger](https://www.ledger-cli.org/) is installed on your machine. See https://www.ledger-cli.org/download.html for how to install ledger on your platform.

Run the following commands to start a sql shell with `example_ledger` (copied from the [Ledger manual](https://www.ledger-cli.org/3.0/doc/ledger3.html#Example-Journal-File)) imported as a table named `LEDGER`.
```
git clone https://github.com/xwkuang5/ledgercalcite.git

cd ledgercalcite

./ledger_sql.sh example_ledger /tmp/scratch
```

## Example
List the tables available.
```
0: jdbc:calcite:model=/tmp/scratch/model.json> !tables
+-----------+-------------+------------+--------------+---------+----------+------------+-----------+---------------------------+----------------+
| TABLE_CAT | TABLE_SCHEM | TABLE_NAME |  TABLE_TYPE  | REMARKS | TYPE_CAT | TYPE_SCHEM | TYPE_NAME | SELF_REFERENCING_COL_NAME | REF_GENERATION |
+-----------+-------------+------------+--------------+---------+----------+------------+-----------+---------------------------+----------------+
|           | LEDGER      | LEDGER     | TABLE        |         |          |            |           |                           |                |
|           | metadata    | COLUMNS    | SYSTEM TABLE |         |          |            |           |                           |                |
|           | metadata    | TABLES     | SYSTEM TABLE |         |          |            |           |                           |                |
+-----------+-------------+------------+--------------+---------+----------+------------+-----------+---------------------------+----------------+
```

Explore the schema of the `LEDGER` table.
```
0: jdbc:calcite:model=/tmp/scratch/model.json> !describe LEDGER
+-----------+-------------+------------+-------------+-----------+----------------+-------------+---------------+----------------+----------------+--------+
| TABLE_CAT | TABLE_SCHEM | TABLE_NAME | COLUMN_NAME | DATA_TYPE |   TYPE_NAME    | COLUMN_SIZE | BUFFER_LENGTH | DECIMAL_DIGITS | NUM_PREC_RADIX | NULLAB |
+-----------+-------------+------------+-------------+-----------+----------------+-------------+---------------+----------------+----------------+--------+
|           | LEDGER      | LEDGER     | TXN_ID      | -5        | BIGINT         | -1          | null          | null           | 10             | 1      |
|           | LEDGER      | LEDGER     | TXN_DATE    | 91        | DATE           | -1          | null          | null           | 10             | 1      |
|           | LEDGER      | LEDGER     | CODE        | 12        | VARCHAR        | -1          | null          | null           | 10             | 1      |
|           | LEDGER      | LEDGER     | PAYEE       | 12        | VARCHAR        | -1          | null          | null           | 10             | 1      |
|           | LEDGER      | LEDGER     | ACCOUNT     | 12        | VARCHAR        | -1          | null          | null           | 10             | 1      |
|           | LEDGER      | LEDGER     | COMMODITY   | 12        | VARCHAR        | -1          | null          | null           | 10             | 1      |
|           | LEDGER      | LEDGER     | QUANTITY    | 3         | DECIMAL(18, 2) | 18          | null          | 2              | 10             | 1      |
|           | LEDGER      | LEDGER     | STATUS      | 12        | VARCHAR        | -1          | null          | null           | 10             | 1      |
+-----------+-------------+------------+-------------+-----------+----------------+-------------+---------------+----------------+----------------+--------+
```

Show the 5 most-recent transactions. See [Calcite documentation](https://calcite.apache.org/docs/reference.html) for syntax of the SQL dialect recognized by the SQL parser.
```
0: jdbc:calcite:model=/tmp/scratch/model.json> SELECT * FROM LEDGER ORDER BY TXN_DATE DESC LIMIT 5;
+--------+------------+------+------------+--------------------------+-----------+----------+---------+
| TXN_ID |  TXN_DATE  | CODE |   PAYEE    |         ACCOUNT          | COMMODITY | QUANTITY | STATUS  |
+--------+------------+------+------------+--------------------------+-----------+----------+---------+
| 12     | 2011-12-01 |      | Sale       | Assets:Checking:Business | $         | 30       | unknown |
| 12     | 2011-12-01 |      | Sale       | Income:Sales             | $         | -30      | unknown |
| 13     | 2011-12-01 |      | Sale       | (Liabilities:Tithe)      | $         | -3.6     | unknown |
| 11     | 2011-01-27 |      | Book Store | Expenses:Books           | $         | 20       | unknown |
| 11     | 2011-01-27 |      | Book Store | Liabilities:MasterCard   | $         | -20      | unknown |
+--------+------------+------+------------+--------------------------+-----------+----------+---------+
```

Find the balances of all the expenses accounts:
```
0: jdbc:calcite:model=/tmp/scratch/model.json> SELECT COMMODITY, SUM(QUANTITY) FROM LEDGER WHERE ACCOUNT LIKE 'Expenses%' GROUP BY COMMODITY;
+-----------+--------+
| COMMODITY | EXPR$1 |
+-----------+--------+
| $         | 6654.0 |
+-----------+--------+
```

## Dependencies

* [Apache Calcite](https://github.com/apache/calcite)
* java (11 or later)
* [ledger](https://www.ledger-cli.org/)
* git
