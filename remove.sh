#!/bin/bash

DIR=`cd "$(dirname "${BASH_SOURCE[0]}")" && pwd`

source $DIR/../mysql-storage/.env
source $DIR/../mysql-storage/concava.env

if [ -z "$MYSQL_STORAGE_DATABASE" ]; then
	echo 'Could not determine storage database.'
	exit 1
fi
if [ -z "$MYSQL_ROOT_PASSWORD" ]; then
	echo 'Could not determine root password.'
	exit 1
fi

ids=(
	ff4c5188293e41ae
	14169265172c41ae
	ffaf5c19163c41ae
	979f81a8121a41ae
	5131fc0f120241ae
	5d0b54ec131e41ae
	c6afaa84170041ae
	e616a5cf292e41ae
	435a4d38153941ae
	598deeda123941ae
	433bc630122841ae
)

for id in ${ids[@]}; do
	echo "[`date`] Removing zero values for $id.."
	result=$(docker exec concavasetupmysqlmqtt_mariadb_1 mysql \
		-u'root' -p"$MYSQL_ROOT_PASSWORD" \
		-e 'DELETE FROM `'"$MYSQL_STORAGE_DATABASE"'`.`'"$id"'` WHERE humid = 0; SELECT ROW_COUNT();' 2>&1)
	status=$?
	count=$(echo -e "$result" | grep -A1 'ROW_COUNT()' | tail -n1)
	[ $status -eq 0 ] \
		&& echo "[`date`] Removed $count rows." \
		|| echo -n "[`date`] Error deleting zero values: $result"
done
