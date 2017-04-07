#!/usr/bin/env bash

# semver.sh
# Based on https://github.com/fmahnke/shell-semver/blob/master/increment_version.sh
semver_inc()
{
    a=( ${version//./ } )

    # If version string is missing or has the wrong number of members, show usage message.
    if [ ${#a[@]} -ne 3 ]
    then
        echo "\$version must be of the format XX.YY.ZZ"
        return
    fi

    # Increment version numbers as requested.
    if [ ! -z $MAJOR ]
    then
        ((a[0]++))
        a[1]=0
        a[2]=0
    fi

    if [ ! -z $MINOR ]
    then
        ((a[1]++))
        a[2]=0
    fi

    if [ ! -z "$PATCH" ]
    then
        ((a[2]++))
    fi

    version="${a[0]}.${a[1]}.${a[2]}"
}

status=$(git status --porcelain)
if [ ! -z "$status" ]; then
    echo -e "There are uncommitted files please commit them or stash them:\n$status"
    exit 1
fi

git pull
version=$(git tag -l [0-9]*.[0-9]*.[0-9]* | tail -n 1)
PATCH=${PATCH:-"$([[ "$MAJOR" || "$MINOR" ]] || echo "1")"}
semver_inc

while true; do
    rand=$RANDOM
    read -p "Type $rand to build production as well or ENTER to skip: " num
    if [ "$num" == "$rand" ]; then
        PRODUCTION=1
        break;
    elif [ -z "$num" ]; then
        PRODUCTION=0
        break;
    fi
done

docker build -t snowflake-connector .
snowflake_connector_version=$(docker run -i -a STDOUT snowflake-connector echo -e "import snowflake.connector\nprint '.'.join(map(str, filter(lambda x:  x != None, snowflake.connector.VERSION)))" | python)

docker tag snowflake-connector:latest snowflake-connector:"$version"
docker tag snowflake-connector:latest snowflake-connector:connector-"$snowflake_connector_version"
docker tag snowflake-connector:latest 030395983582.dkr.ecr.us-east-1.amazonaws.com/snowflake-connector:latest
docker tag snowflake-connector:latest 030395983582.dkr.ecr.us-east-1.amazonaws.com/snowflake-connector:"$version"
docker tag snowflake-connector:latest 030395983582.dkr.ecr.us-east-1.amazonaws.com/snowflake-connector:connector-"$snowflake_connector_version"
if [ "$PRODUCTION" = "1" ]; then
    docker tag snowflake-connector:latest 030395983582.dkr.ecr.us-east-1.amazonaws.com/snowflake-connector:production
fi
`aws ecr get-login`
docker push 030395983582.dkr.ecr.us-east-1.amazonaws.com/snowflake-connector

git tag "$version"
git push --tags
