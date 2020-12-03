#!/bin/bash

az policy definition create --name tagging-policy \
                            --display-name "Enforce resource tagging policy" \
                            --description "This policy ensures all indexed resources in your subscription have tags and deny deployment if they do not." \
                            --rules tagging-policy.json --params tagging-policy-param.json \
                            --mode Indexed