#!/bin/bash

# usage: ./deploy.sh master
# license: public domain

NOW=`date +%s`

BRANCH=$1
SHA1=`echo -n $NOW | openssl dgst -sha1 |awk '{print $NF}'`

[[ -z "$BRANCH" ]] && { echo "must pass a branch param" ; exit 1; }

# Main variables to modify for your account
AWS_ACCOUNT_ID=12346880000
NAME='test-app'
EB_BUCKET='test-app-versions'
REGION='us-east-1'

VERSION=$BRANCH-$SHA1
ZIP=$VERSION.zip

aws configure set default.region $REGION

# Authenticate against our Docker registry
eval $(aws ecr get-login --no-include-email)

# Build and push the image
docker build -t $NAME:$VERSION .
docker tag $NAME:$VERSION $AWS_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/$NAME:$VERSION
docker push $AWS_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/$NAME:$VERSION


# Replace variables in the Dockerrun file before zipping
cp dockerrun.aws.template Dockerrun.aws.json
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

# Cleanup

rm Dockerrun.aws.json
rm Dockerrun.aws.json=
rm $ZIP
