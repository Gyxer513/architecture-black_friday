#!/bin/bash

# 1. Инициализируем configSrv
docker compose exec -T configSrv mongosh --port 27017 --quiet <<EOF
rs.initiate({
  _id: "config_server",
  configsvr: true,
  members: [
    { _id: 0, host: "configSrv:27017" }
  ]
})
EOF

sleep 5

# 2. Инициализируем shard1 с двумя репликами
docker compose exec -T shard1-1 mongosh --port 27018 --quiet <<EOF
rs.initiate({
  _id: "shard1",
  members: [
    { _id: 0, host: "shard1-1:27018" },
    { _id: 1, host: "shard1-2:27019" }
  ]
})
EOF

sleep 5

# 3. Инициализируем shard2 с двумя репликами
docker compose exec -T shard2-1 mongosh --port 27020 --quiet <<EOF
rs.initiate({
  _id: "shard2",
  members: [
    { _id: 0, host: "shard2-1:27020" },
    { _id: 1, host: "shard2-2:27021" }
  ]
})
EOF

sleep 10

# 4. Добавляем шарды к mongos:
docker compose exec -T mongos_router mongosh --port 27022 --quiet <<EOF
sh.addShard("shard1/shard1-1:27018,shard1-2:27019")
sh.addShard("shard2/shard2-1:27020,shard2-2:27021")
EOF

sleep 10

# 5. Включаем шардирование:
docker compose exec -T mongos_router mongosh --port 27022 --quiet <<EOF
sh.enableSharding("somedb")
sh.shardCollection("somedb.helloDoc", {"_id": "hashed"})
EOF

sleep 5

# 6. Вставляем документы через mongos_router только сейчас!
docker compose exec -T mongos_router mongosh --port 27022 --quiet <<EOF
use somedb
for (var i = 0; i < 1001; i++) db.helloDoc.insertOne({age:i, name:"ly"+i})
EOF

echo "=== Готово! ==="
