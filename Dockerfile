# Build me!
# docker build -t snowflake-connector .
# docker push inmoji/snowflake-connector:latest


FROM amazonlinux

# Install dependencies
RUN yum update -y
RUN yum install -y python27-pip gcc libffi-devel openssl-devel python27-devel
RUN pip install snowflake-connector-python python-json-logger

RUN yum autoremove -y gcc libffi-devel openssl-devel python27-devel
