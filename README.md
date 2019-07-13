# AWS Lambda Authenticator for OIDC Token Authentication

This project contains a generic token authorizer AWS Lambda function
that can be used as authorizer function in an Api Gateway project.


## Deployment

```
./scripts/deploy.sh
```

The script will create a dedicated Codepipeline and output its url
after creation.