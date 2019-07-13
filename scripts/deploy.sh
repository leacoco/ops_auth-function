#!/usr/bin/env bash

APP_NAME="ops-auth-function"
BRANCH_NAME=$(git rev-parse --abbrev-ref HEAD)
ENVIRONMENT=${ENVIRONMENT:-live}

GITHUB_REPO=$(git remote -v | grep fetch | cut -d'/' -f2 | cut -d' ' -f1 | sed 's/\.git//')
LIVE_ACCOUNT_ID="895501758625"
ACCOUNT_ENVIRONMENT=live

if [[ "${BRANCH_NAME}" == "master" ]]; then
    PIPELINE_ENVIRONMENT=live
else
    if [[ -f .pipeline-tag ]]; then
        PIPELINE_ENVIRONMENT=$(cat .pipeline-tag)
     else
        PIPELINE_ENVIRONMENT=$(rig | head -1 | sed 's/ /\-/' |  tr '[:upper:]' '[:lower:]')
        echo $PIPELINE_ENVIRONMENT > .pipeline-tag
    fi
fi

APP_NAME="${APP_NAME}-${PIPELINE_ENVIRONMENT}"

ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

if [[ "${ACCOUNT_ID}" != "${LIVE_ACCOUNT_ID}" ]]; then
    echo "Please make sure you deploy in private account" && exit 1
fi

echo "Deploy cloudformation/pipeline.yaml..."
aws cloudformation deploy \
    --template-file cloudformation/pipeline.yaml \
    --stack-name ${APP_NAME}-pl \
    --parameter-overrides \
        AppName=${APP_NAME} \
        PipelineEnvironment=${PIPELINE_ENVIRONMENT} \
        AccountEnvironment=${ACCOUNT_ENVIRONMENT} \
        GithubRepo=${GITHUB_REPO} \
        GithubBranch=${BRANCH_NAME} \
    --capabilities CAPABILITY_NAMED_IAM

echo
echo "Environment: ${ENVIRONMENT}"
echo -n "Codepipeline Url: "
aws cloudformation describe-stacks \
    --stack-name ${APP_NAME}-pl \
    --query Stacks[0].Outputs[?OutputKey==\'PipelineUrl\'].OutputValue \
    --output text
