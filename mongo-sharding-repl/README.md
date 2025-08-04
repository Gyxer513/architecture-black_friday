# pymongo-api

## Как запустить

Запускаем mongodb и приложение

```shell
docker compose up -d
```

Заполняем mongodb данными

```shell
./scripts/init_mongo_cluster.sh
```

## Ручная проверка: 

### Общие записи в базе

```shell
docker compose exec -T mongos_router mongosh --port 27022 --quiet <<EOF
use somedb
db.helloDoc.countDocuments()
EOF
```

### Записи в шарде 1

```shell
docker compose exec -T shard1-1 mongosh --port 27018 --quiet <<EOF
use somedb
db.helloDoc.countDocuments()
EOF
```

### Записи в реплике шарда 1

```shell
docker compose exec -T shard1-2 mongosh --port 27019 --quiet <<EOF
rs.secondaryOk()
use somedb
db.helloDoc.countDocuments()
EOF
```

### Записи в шарде 2

```shell
docker compose exec -T shard2-1 mongosh --port 27020 --quiet <<EOF
use somedb
db.helloDoc.countDocuments()
EOF
```

### Записи в реплике шарда 2

```shell
docker compose exec -T shard2-2 mongosh --port 27021 --quiet <<EOF
rs.secondaryOk()
use somedb
db.helloDoc.countDocuments()
EOF
```

Откройте в браузере http://http://localhost:8080

## Доступные эндпоинты

Список доступных эндпоинтов, swagger http://http://localhost:8080/docs