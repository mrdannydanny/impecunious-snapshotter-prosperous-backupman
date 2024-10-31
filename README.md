# impecunious-snapshotter-prosperous-backupman
the duality of an ubuntuhero

running this will cost you money$$$ (snapshots module and others in the future. Be aware)

## How to take snapshots by tag? (ignore step 1 if you already have existing volumes ready for the snapshot process)
```
1. spin up an ec2 and attach two volumes for testing 

terraform apply -target="module.dummy-ec2" -target="module.volume-to-attach" 

2. snapshot by tag (environment)

terraform apply -target="module.snapshot-by-tag"
```

## How to create backups using the backup plan? (ignore step 1 if you already have existing volumes ready for the backup process)

```
terraform apply -target="module.dummy-ec2" -target="module.volume-to-attach" 

terraform apply -target="module.backup-plan"
```