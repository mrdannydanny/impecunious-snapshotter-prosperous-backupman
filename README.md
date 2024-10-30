# impecunious-snapshotter-prosperous-backupman
the duality of an ubuntuhero

running this will cost you money$$$ (snapshots module and others in the future. Be aware)

```
### spin up an ec2 and attach two volumes for testing 

terraform apply -target="module.dummy-ec2" -target="module.volume-to-attach" 

### snapshot by tag (environment)

terraform apply -target="module.snapshot-by-tag"
```