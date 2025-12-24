#!/bin/bash

OUTPUT_FILE="aws_vm_list.csv"

# Get AWS Account ID
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

echo "account_id,region,instance_id,name,launch_time,state" > $OUTPUT_FILE

# Loop through all regions
for REGION in $(aws ec2 describe-regions --query "Regions[].RegionName" --output text); do
    echo "Checking region: $REGION"

    # Query instances in this region
    aws ec2 describe-instances --region $REGION \
        --query "Reservations[].Instances[].{ID:InstanceId,Launch:LaunchTime,State:State.Name,Name:Tags[?Key=='Name']|[0].Value}" \
        --output text | while read -r ID Launch State Name; do

        # Replace empty name with 'N/A'
        if [[ -z "$Name" ]]; then Name="N/A"; fi

        echo "$ACCOUNT_ID,$REGION,$ID,$Name,$Launch,$State" >> $OUTPUT_FILE
    done
done

echo "CSV file generated: $OUTPUT_FILE"
echo "AWS Account ID: $ACCOUNT_ID"

