#!/bin/bash
# NOTE: You must set your default region ahead of this

SKIP_BUCKETS="SomeBucketName|SomeOtherBucketName"
IFS='
'
for BUCKET in $(aws s3api list-buckets | jq '.Buckets|to_entries[]|.value.Name' -r); do 
    echo "############### $BUCKET ###########################"; 
    if [[ "$(echo $BUCKET | egrep -v "$SKIP_BUCKETS")" ]]; then
        echo DELETE $BUCKET
        /bin/rm -f keys*
        echo "" > keys
        aws s3api list-objects --bucket $BUCKET | jq '.Contents|to_entries[]|.value.Key' -r > keys
        if [[ $(cat keys | wc -l) -gt 0 ]]; then
            echo "$(cat keys | wc -l) objects to delete"
            split -l 1000 keys keys_
            for fname in $(ls keys_*); do
                echo '{
        "Objects": [' > delete.json
                first=1
                for key in $(cat $fname); do
                    if [[ $first -ne 1 ]]; then echo -n "        ," >> delete.json; else echo -n "        " >> delete.json; fi
                    echo '{"Key": "'$key'"}' >> delete.json;
                    first=0
                done
                echo '    ],
                    "Quiet": true
    }' >> delete.json
                tail delete.json
                echo "### ^^ $BUCKET $fname ^^ ###"
                aws s3api delete-objects --bucket=$BUCKET --delete file://delete.json
            done
         else
             echo "$BUCKET was EMPTY already"
         fi
        /bin/rm -f keys*
        echo aws s3api delete-bucket --bucket $BUCKET
        aws s3api delete-bucket --bucket $BUCKET
    fi
done
