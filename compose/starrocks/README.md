# Starrocks
---
## 1. Notes

* Common
  * FE node should be ready before CN nodes start
  * If CN nodes failed to start because they are registered in the FE node already, log into Starrocks and drop those CN nodes
  * CN process leaves a PID file at ${STARROCK_HOME}/cn.pid, if the file is available, CN process startup will failed
* Shared-data mode
  * Set aws_s3_use_aws_sdk_default_behavior=false or FE node won't use S3 credentials from fe.conf
