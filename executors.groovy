import jenkins.model.*

// Disable executors on master
Jenkins.instance.setNumExecutors(0)
