# Zerto-MongoDB-Checkpoints-Linux
Version 2.0

This script is used to add a quiesced User Checkpoint to the Zerto Journal for a Linux based MongoDB server. The result is that MongoDB will flush all pending writes to disk, and pause new writes long enough for Zerto to insert a checkpoint into the journal. Then it unlocks the tables and resumes normal operations

## Getting Started

There are several pieces to this project. The script that does the work is placed on your Linux based MySQL server, while the helper script that finds your VPG ID can be ran from any Windows machine that has Zerto Powershell modules installed.

At a high level the process for a MongoDB Journal Checkpoint looks like this:
1. Cron (or some other scheduler) calls the ZertoMongoCheckpoint.sh BaSH script
2. The script connects to the Zerto REST API for authentication.
3. The script then commands MongoDB to lock tables and flush to disk.
4. The script then calles the Zerto REST API to insert a checkpoint.
5. The script then commands MongoDB to unlock tables.

## Prerequisites

* Zerto PowerShell Module must be installed on the Windows Machine
* You must get the VPG ID (can be done by running the GetVPGID.ps1 powershell script.


## Installing

Download or clone the git repository to your Linux MongoDB server, then make the bash scripts (ZertoMongoCheckpoint.sh) executable.

```
git clone https://www.github.com/zerto-ta-public/Zerto-MongoDB-Checkpoints-Linux/
chmod +x ZertoMongoCheckpoint.sh
```

Next, schedule the script to run as often as you would like. Remember that no application can talk to the database for the second or so that it takes to insert the checkpoint.

You can edit the cron file with crontab -e

```
crontab -e
``` 

## Usage

For a full walkthrough of this project please see https://www.jpaul.me/

## Versioning

This script is considered the initial release and version 1.0.0 

## Authors

* **Justin Paul** - *Initial work* - [recklessop](https://github.com/recklessop) - [Blog](https://jpaul.me)

## Contributors
* **Shannon Snowden** - *Script Review* - [shannonsnowden](https://github.com/shannonsnowden) - [Blog](http://virtualizationinformation.com/)

## License

This project is licensed under the GNU GPLv3 License - see the [LICENSE.md](LICENSE.md) file for details

## Acknowledgments

* Google
* Zerto Documentation
* etc
