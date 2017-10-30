/***********************************************************************************************************************************
Command and Option Configuration

Automatically generated by Build.pm -- do not modify directly.
***********************************************************************************************************************************/
#ifndef XS_CONFIG_CONFIG_AUTO_H
#define XS_CONFIG_CONFIG_AUTO_H

/***********************************************************************************************************************************
Command constants
***********************************************************************************************************************************/
#define CFGCMD_ARCHIVE_GET                                          cfgCmdArchiveGet
#define CFGCMD_ARCHIVE_PUSH                                         cfgCmdArchivePush
#define CFGCMD_BACKUP                                               cfgCmdBackup
#define CFGCMD_CHECK                                                cfgCmdCheck
#define CFGCMD_EXPIRE                                               cfgCmdExpire
#define CFGCMD_HELP                                                 cfgCmdHelp
#define CFGCMD_INFO                                                 cfgCmdInfo
#define CFGCMD_LOCAL                                                cfgCmdLocal
#define CFGCMD_REMOTE                                               cfgCmdRemote
#define CFGCMD_RESTORE                                              cfgCmdRestore
#define CFGCMD_STANZA_CREATE                                        cfgCmdStanzaCreate
#define CFGCMD_STANZA_UPGRADE                                       cfgCmdStanzaUpgrade
#define CFGCMD_START                                                cfgCmdStart
#define CFGCMD_STOP                                                 cfgCmdStop
#define CFGCMD_VERSION                                              cfgCmdVersion

/***********************************************************************************************************************************
Option constants
***********************************************************************************************************************************/
#define CFGOPT_ARCHIVE_ASYNC                                        cfgOptionArchiveAsync
#define CFGOPT_ARCHIVE_CHECK                                        cfgOptionArchiveCheck
#define CFGOPT_ARCHIVE_COPY                                         cfgOptionArchiveCopy
#define CFGOPT_ARCHIVE_MAX_MB                                       cfgOptionArchiveMaxMb
#define CFGOPT_ARCHIVE_QUEUE_MAX                                    cfgOptionArchiveQueueMax
#define CFGOPT_ARCHIVE_TIMEOUT                                      cfgOptionArchiveTimeout
#define CFGOPT_BACKUP_CMD                                           cfgOptionBackupCmd
#define CFGOPT_BACKUP_CONFIG                                        cfgOptionBackupConfig
#define CFGOPT_BACKUP_HOST                                          cfgOptionBackupHost
#define CFGOPT_BACKUP_SSH_PORT                                      cfgOptionBackupSshPort
#define CFGOPT_BACKUP_STANDBY                                       cfgOptionBackupStandby
#define CFGOPT_BACKUP_USER                                          cfgOptionBackupUser
#define CFGOPT_BUFFER_SIZE                                          cfgOptionBufferSize
#define CFGOPT_CHECKSUM_PAGE                                        cfgOptionChecksumPage
#define CFGOPT_CMD_SSH                                              cfgOptionCmdSsh
#define CFGOPT_COMMAND                                              cfgOptionCommand
#define CFGOPT_COMPRESS                                             cfgOptionCompress
#define CFGOPT_COMPRESS_LEVEL                                       cfgOptionCompressLevel
#define CFGOPT_COMPRESS_LEVEL_NETWORK                               cfgOptionCompressLevelNetwork
#define CFGOPT_CONFIG                                               cfgOptionConfig
#define CFGOPT_DB_CMD                                               cfgOptionDbCmd
#define CFGOPT_DB_CONFIG                                            cfgOptionDbConfig
#define CFGOPT_DB_HOST                                              cfgOptionDbHost
#define CFGOPT_DB_INCLUDE                                           cfgOptionDbInclude
#define CFGOPT_DB_PATH                                              cfgOptionDbPath
#define CFGOPT_DB_PORT                                              cfgOptionDbPort
#define CFGOPT_DB_SOCKET_PATH                                       cfgOptionDbSocketPath
#define CFGOPT_DB_SSH_PORT                                          cfgOptionDbSshPort
#define CFGOPT_DB_TIMEOUT                                           cfgOptionDbTimeout
#define CFGOPT_DB_USER                                              cfgOptionDbUser
#define CFGOPT_DELTA                                                cfgOptionDelta
#define CFGOPT_FORCE                                                cfgOptionForce
#define CFGOPT_HARDLINK                                             cfgOptionHardlink
#define CFGOPT_HOST_ID                                              cfgOptionHostId
#define CFGOPT_LINK_ALL                                             cfgOptionLinkAll
#define CFGOPT_LINK_MAP                                             cfgOptionLinkMap
#define CFGOPT_LOCK_PATH                                            cfgOptionLockPath
#define CFGOPT_LOG_LEVEL_CONSOLE                                    cfgOptionLogLevelConsole
#define CFGOPT_LOG_LEVEL_FILE                                       cfgOptionLogLevelFile
#define CFGOPT_LOG_LEVEL_STDERR                                     cfgOptionLogLevelStderr
#define CFGOPT_LOG_PATH                                             cfgOptionLogPath
#define CFGOPT_LOG_TIMESTAMP                                        cfgOptionLogTimestamp
#define CFGOPT_MANIFEST_SAVE_THRESHOLD                              cfgOptionManifestSaveThreshold
#define CFGOPT_NEUTRAL_UMASK                                        cfgOptionNeutralUmask
#define CFGOPT_ONLINE                                               cfgOptionOnline
#define CFGOPT_OUTPUT                                               cfgOptionOutput
#define CFGOPT_PROCESS                                              cfgOptionProcess
#define CFGOPT_PROCESS_MAX                                          cfgOptionProcessMax
#define CFGOPT_PROTOCOL_TIMEOUT                                     cfgOptionProtocolTimeout
#define CFGOPT_RECOVERY_OPTION                                      cfgOptionRecoveryOption
#define CFGOPT_REPO_CIPHER_KEY                                      cfgOptionRepoCipherKey
#define CFGOPT_REPO_CIPHER_TYPE                                     cfgOptionRepoCipherType
#define CFGOPT_REPO_PATH                                            cfgOptionRepoPath
#define CFGOPT_REPO_S3_BUCKET                                       cfgOptionRepoS3Bucket
#define CFGOPT_REPO_S3_CA_FILE                                      cfgOptionRepoS3CaFile
#define CFGOPT_REPO_S3_CA_PATH                                      cfgOptionRepoS3CaPath
#define CFGOPT_REPO_S3_ENDPOINT                                     cfgOptionRepoS3Endpoint
#define CFGOPT_REPO_S3_HOST                                         cfgOptionRepoS3Host
#define CFGOPT_REPO_S3_KEY                                          cfgOptionRepoS3Key
#define CFGOPT_REPO_S3_KEY_SECRET                                   cfgOptionRepoS3KeySecret
#define CFGOPT_REPO_S3_REGION                                       cfgOptionRepoS3Region
#define CFGOPT_REPO_S3_VERIFY_SSL                                   cfgOptionRepoS3VerifySsl
#define CFGOPT_REPO_TYPE                                            cfgOptionRepoType
#define CFGOPT_RESUME                                               cfgOptionResume
#define CFGOPT_RETENTION_ARCHIVE                                    cfgOptionRetentionArchive
#define CFGOPT_RETENTION_ARCHIVE_TYPE                               cfgOptionRetentionArchiveType
#define CFGOPT_RETENTION_DIFF                                       cfgOptionRetentionDiff
#define CFGOPT_RETENTION_FULL                                       cfgOptionRetentionFull
#define CFGOPT_SET                                                  cfgOptionSet
#define CFGOPT_SPOOL_PATH                                           cfgOptionSpoolPath
#define CFGOPT_STANZA                                               cfgOptionStanza
#define CFGOPT_START_FAST                                           cfgOptionStartFast
#define CFGOPT_STOP_AUTO                                            cfgOptionStopAuto
#define CFGOPT_TABLESPACE_MAP                                       cfgOptionTablespaceMap
#define CFGOPT_TABLESPACE_MAP_ALL                                   cfgOptionTablespaceMapAll
#define CFGOPT_TARGET                                               cfgOptionTarget
#define CFGOPT_TARGET_ACTION                                        cfgOptionTargetAction
#define CFGOPT_TARGET_EXCLUSIVE                                     cfgOptionTargetExclusive
#define CFGOPT_TARGET_TIMELINE                                      cfgOptionTargetTimeline
#define CFGOPT_TEST                                                 cfgOptionTest
#define CFGOPT_TEST_DELAY                                           cfgOptionTestDelay
#define CFGOPT_TEST_POINT                                           cfgOptionTestPoint
#define CFGOPT_TYPE                                                 cfgOptionType

#endif
