# Build me!
# docker build -t snowflake-connector --no-cache .
# docker push inmoji/snowflake-connector:latest



## ECR images tends to be outdateded
## Pull AWS amazonlinux from ECR:
# `aws ecr get-login --registry-ids 137112412989 | sed -e 's/-e none//'`
# docker pull 137112412989.dkr.ecr.us-east-1.amazonaws.com/amazonlinux:latest
# FROM 137112412989.dkr.ecr.us-west-2.amazonaws.com/amazonlinux:latest
FROM amazonlinux

# Install dependencies
RUN yum update -y -q && yum install -q -y python27-pip gcc libffi-devel openssl-devel python27-devel && pip install --upgrade --no-cache-dir --quiet --compile snowflake-connector-python python-json-logger && yum autoremove -q -y python27-pip gcc libffi-devel openssl-devel python27-devel && yum clean all
