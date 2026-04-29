# Lab 3: Static Website on S3 with CloudFront

## Objective
Host a static website on S3 with global distribution via CloudFront.

## Estimated Duration
45 minutes

## Instructions

### Step 1: Create S3 Bucket
```bash
aws s3 mb s3://my-static-website-$(date +%s) \
    --region us-east-1
```

### Step 2: Configure Bucket for Website Hosting
```bash
aws s3api put-bucket-website \
    --bucket my-static-website-xxx \
    --website-configuration file://website-config.json
```

Content of `website-config.json`:
```json
{
  "IndexDocument": {"Suffix": "index.html"},
  "ErrorDocument": {"Key": "error.html"}
}
```

### Step 3: Upload Content
```bash
aws s3 sync ./website-content s3://my-static-website-xxx \
    --acl public-read
```

### Step 4: Bucket Policy
```json
{
  "Version": "2012-10-17",
  "Statement": [{
    "Sid": "PublicReadGetObject",
    "Effect": "Allow",
    "Principal": "*",
    "Action": "s3:GetObject",
    "Resource": "arn:aws:s3:::my-static-website-xxx/*"
  }]
}
```

### Step 5: Create CloudFront Distribution
```bash
aws cloudfront create-distribution \
    --origin-domain-name my-static-website-xxx.s3.amazonaws.com \
    --default-root-object index.html
```

### Step 6: Configure DNS with Route 53
```bash
aws route53 change-resource-record-sets \
    --hosted-zone-id Z123456789 \
    --change-batch file://dns-changes.json
```

## Testing
1. Verify direct bucket access
2. Verify CloudFront distribution
3. Test cache invalidation

## Additional Challenges
1. Configure custom SSL certificate
2. Implement OAI (Origin Access Identity)
3. Configure gzip compression
4. Add security headers

## Cleanup
1. Delete CloudFront distribution
2. Empty and delete S3 bucket
3. Delete DNS records
