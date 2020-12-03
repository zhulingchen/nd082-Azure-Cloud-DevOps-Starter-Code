#!/bin/bash

az policy assignment create --name tagging-policy-assignment \
                            --display-name "Enforce resource tagging assignment" \
                            --policy tagging-policy \
                            --params "{ \"tagName\": {\"value\": \"Name\"} }"