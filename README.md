# aws_tricks
Just a place to save some script tid bits for future use


## delete_buckets.sh

Use case: I have dozens of S3 buckets with thousands of files in each and needed to clean some house. So, wrote a little bash script that uses the aws cli to list-objects, then delete-objects, then delete-bucket. I needed to keep a couple buckets, so added a feature to list buckets to SKIP_BUKETS.


