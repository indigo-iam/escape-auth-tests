*** Settings ***

Library    OperatingSystem
Library    String
Library    Collections

Resource   common/voms.robot
Resource   common/oidc-agent.robot
Resource   common/endpoint.robot
Resource   common/curl.robot
Resource   common/utils.robot

Variables   test/variables.yaml

Documentation  IAM basic checks

Force Tags   iam
