The purpose of this Terraform module is to create resources in the AWS account that needs to be crawled by Kaleidoscope's AWS Blueprint.

This README describes the usage of this module as well the resources that are created and their need.

# Usage of this module

The ```main.tf``` file shows how to import this module. We use Terraform's concept of local modules for now.

The variables needed by the module and their description can be seen in [the variables file](./kscope_crawl/variables.tf). All of these variables basically are used to customize the names of the created resources. (You can read the details of these resources and their need in the next section). All of the variables have sane default values, except ```bucket_name``` which is mandatory.

The module outputs four variables, which are used to configure the AWS Blueprint in the Kaleidoscope application. You can see the descriptions of the outputs in [the output file](./kscope_crawl/output.tf)

You must output these variables again in your root module, as shown in the ```output``` blocks of [the main file](./main.tf). 

All of the output values will be shown when you run the apply command except the ```secretKey``` value since that is a sensitive value so Terraform by default hides it. You can run ```terraform output --json``` to show all output values in JSON format which will also show the ```secretKey```.

# Infrastructure needed for crawling
The infrastructure needed for crawling can be divided into two parts:

## 1. Data Crawl Infrastructure
Data crawls are the meat of the crawler, they crawl all the resources in the AWS account. For data crawls to work we need the following infrastructure:

1. An AWS IAM user with its access keys. It has the AWS managed `ReadOnlyAccess` policy attached to it which allows it to only read all the resources in the account.

## 2. Event Crawl Infrastructure

Event crawls ingest the events produced by AWS and bind them to the AWS resources crawled by the data crawls to produce a 360 degree view capable of providing more powerful insights. 

For event crawls to work we need the following infrastructure:

1. **S3 bucket**: An S3 bucket that is used by CloudTrail for storing its logs. It also attaches relevant policies allowing CloudTrail to access this bucket.

2. **CloudTrail**: A multi region CloudTrail with global service events enabled. It also sends notifications to an SNS topic when it dumps a new log file. It also enables [Data events for S3](https://docs.aws.amazon.com/awscloudtrail/latest/userguide/logging-data-events-with-cloudtrail.html), but it excludes the bucket that receives the event dump files to avoid an infinite cycle of events. **Note** If you have more CloudTrail logging enabled in your account then make sure you manually exclude the log buckets of those trails from the trail that this module creates. 

3. **SNS topic**:  This topic is used by CloudTrail to send a notification whenever CloudTrail dumps a new events log file in S3. This is needed because the optimal way to get events from CloudTrail is to use the JSON based event log files that CloudTrail dumps in the S3 bucket. To get notified whenever a new dump is done, we have to use SNS. We also create an SNS policy for this topic that allows CloudTrail to publish notifications to this topic.

4. **SQS**: This is subscribed to the SNS topic and this is what out crawler polls periodically to receive the name of the latest log dump file. We also create and attach a relevant IAM policy that allows our SNS topic to sent messages to this SQS.

![](./images/crawl_infra.png)


# Setting up events in AWS manually

This is not needed anymore since we have this Terraform module doing the creation and management for us but this is still kept here for legacy reasons.

## Creating the trail

1. Go to the AWS Cloudtrail Dashboard.
2. Click `Create trail` to jump to the trail creation form.
3. Fill in the relevant information as you see fit.
4. Specifically, turn on SNS notifications by checking `SNS notification delivery`,
   and select an existing topic or create a new one. Please make sure that this topic is not used for any other purpose across the account.
5. On the next screen, turn on both `Management` and `Data` events.
6. For management events
   1. Check both `Read` and `Write` events.
7. For data events
   1. In the Data event source dropdown select `S3`
   2. Select `Read` and `Write` for all current and future S3 buckets.
8. Click `Next` at the bottom right to jump to the next page that will show you the details of the trail.
9. If everything looks good, click `Save` to create the trail.

## Setting up SQS to receive event notifications

1. Go to the SQS dashboard.
2. Click `Create queue`.
3. The type of queue should be set to `Standard`. Leave other settings to default.
4. Click on `Create queue` on the bottom right of the screen.
5. It should take you to the newly created queue's dashboard. If it does not, go to the SQS dashboard, click on Queues, and then click on the queue that you just created.
6. On the bottom right, click on `Subscribe to Amazon SNS topic` and select the SNS topic ARN that you created in step 4 of "creating the trail".
7. Click `Save` to finalize.
8. The URL of this SQS shall be used to configure the AWS Blueprint in your Kaleidoscope deployment.

**Note:** If you have multiple deployments of Kaleidoscope that monitor the same AWS account, make sure that you have separate queues for each of those deployments since SQS allows a message to be read only once. Having multiple queues is fairly simple, just follow the steps above to create another queue, and subscribe it to the same SNS topic ARN.

## Preventing cyclical event generation

Cyclical event generation occurs because Cloudtrail sends the logs to an S3 bucket, and when you have data events enabled for that S3, that logging will get recorded as a separate event, which will again be logged and thus generate another event, and so on. To prevent this, follow the following steps:

1. Go to `Trails` menu from CloudTrail Dashboard and click on the trail you have configured to use with Kaleidoscope.
2. Click on `Edit` button atop the Data events subsection.
3. Scroll down and click on `Switch to Advanced Data Selectors`
4. Select `S3` from the Data event type dropdown.
5. Select `Custom` from the Log selector template dropdown.
6. Select `resources.ARN` from the field dropdown.
7. Select `does not start with` from the operator dropdown.
8. Click on `Browse` and select the S3 bucket that you have configured to send the logs of this particular CloudTrail to. You might also want to select S3 buckets for other CloudTrails, in case you have multiple CloudTrails enabled.