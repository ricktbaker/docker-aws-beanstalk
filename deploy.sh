#!/bin/bash

# usage: ./deploy.sh master
# license: public domain

NOW=`date +%s`

BRANCH=$1
SHA1=`echo -n $NOW | openssl dgst -sha1 |awk '{print $NF}'`

AWS_ACCOUNT_ID=12345678900
NAME=name-of-service-to-deploy
EB_BUCKET=aws-s3-bucket-to-hold-application-versions

VERSION=$BRANCH-$SHA1
ZIP=$VERSION.zip

aws configure set default.region us-east-1

# Authenticate against our Docker registry
eval $(aws ecr get-login)

# Build and push the image
docker build -t $NAME:$VERSION .
docker tag $NAME:$VERSION $AWS_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/$NAME:$VERSION
docker push $AWS_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/$NAME:$VERSION

# Replace varialbes in the Dockerrun file before zipping
sed -i='' "s/<AWS_ACCOUNT_ID>/$AWS_ACCOUNT_ID/" Dockerrun.aws.json
sed -i='' "s/<NAME>/$NAME/" Dockerrun.aws.json
sed -i='' "s/<TAG>/$VERSION/" Dockerrun.aws.json

# Zip up the Dockerrun file
zip -r $ZIP Dockerrun.aws.json

# Push file to s3
aws s3 cp $ZIP s3://$EB_BUCKET/$ZIP

# Create a new application version with the zipped up Dockerrun file
aws elasticbeanstalk create-application-version --application-name $NAME-application \
    --version-label $VERSION --source-bundle S3Bucket=$EB_BUCKET,S3Key=$ZIP

# Update the environment to use the new application version
aws elasticbeanstalk update-environment --environment-name $NAME \
      --version-label $VERSION
