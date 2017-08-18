## Sample docker app deployed to beanstak

This is a simple node app (hapi.js) inside a docker container that can be run locally, and also deployed to AWS beanstalk using docker images stored in AWS ECR.

## Deploying to beanstalk via shell

You can deploy this locally fairly simple.   You'll need AWS credentials with access to AWS ECR and ElasticBeanstalk.

Credentials should be saved locally so they do not need to be in your repo, see more about this [here](http://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html)
and [here](http://docs.aws.amazon.com/cli/latest/userguide/cli-config-files.html)

  - Create your beanstalk application
  - Create your s3 bucket to hold your application versions
  - Create your ECR repository to hold your docker image (name should be the same as your beanstalk application for simplicity)
  - Modify variables in deploy.sh with the above
  - Modify anything else in the dockerrun.aws.template file for you needs, instance size, environment variables, etc.

`./deploy.sh production`

Will deploy your current code with the 'production' version label.

## Deploying via Continuous Integration

Will get to this soon.  I normally use CircleCi, so will update these docs shortly with what you'll need for that.
