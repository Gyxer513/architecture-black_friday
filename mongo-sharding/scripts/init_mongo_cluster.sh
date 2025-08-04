#!/bin/bash

# 1. Инициализируем configSrv
docker compose exec -T configSrv mongosh --port 27017 --quiet <<EOF
rs.initiate({
  _id: "config_server",
  configsvr: true,
  members: [ { _id : 0, host : "configSrv:27017" } ]
})
EOF

# 2. Инициализируем shard1 и shard2
docker compose exec -T shard1 mongosh --port 27018 --quiet <<EOF
rs.initiate({
  _id: "shard1",
  members: [ { _id : 0, host : "shard1:27018" } ]
})
EOF

docker compose exec -T shard2 mongosh --port 27019 --quiet <<EOF
rs.initiate({
  _id: "shard2",
  members: [ { _id : 0, host : "shard2:27019" } ]
})
EOF

# 3. Добавляем шарды к mongos:
sleep 10
docker compose exec -T mongos_router mongosh --port 27020 --quiet <<EOF
sh.addShard("shard1/shard1:27018")
sh.addShard("shard2/shard2:27019")
EOF

# 4. Включаем шардирование:
docker compose exec -T mongos_router mongosh --port 27020 --quiet <<EOF
sh.enableSharding("somedb")
sh.shardCollection("somedb.helloDoc", {"_id": "hashed"})
EOF

# 5. Вставляем документы через mongos_router только сейчас!
docker compose exec -T mongos_router mongosh --port 27020 --quiet <<EOF
use somedb
for (var i = 0; i < 1001; i++) db.helloDoc.insertOne({age:i, name:"ly"+i})
EOF

echo "=== Готово! ==="
