# Build me!
# docker build -t snowflake-connector --no-cache .
# docker push inmoji/snowflake-connector:latest

## PyPI API:
# https://pypi.python.org/pypi/snowflake-connector-python/json



## ECR images tends to be outdateded
## Pull AWS amazonlinux from ECR:
# `aws ecr get-login --registry-ids 137112412989 | sed -e 's/-e none//'`
# docker pull 137112412989.dkr.ecr.us-east-1.amazonaws.com/amazonlinux:latest
# FROM 137112412989.dkr.ecr.us-west-2.amazonaws.com/amazonlinux:latest
FROM amazonlinux

# Install dependencies
RUN yum update -y -q && yum install -q -y python3 && pip3 install --upgrade --no-cache-dir --quiet --compile snowflake-connector-python python-json-logger && yum clean all -q && rm -rf /var/cache/yum
