# leftovers

Runs the leftovers[https://github.com/genevieve/leftovers] utility

steps:
- name: 'gcr.io/cloud-community-builders/leftovers
  args: ['-i=gcp' ,'-f=dev','--gcp-service-account-key=<location-of-service-account-json-file>']
