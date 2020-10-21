*** Settings ***

Library    OperatingSystem
Library    String
Library    Collections

Resource   common/oidc-agent.robot
Resource   common/endpoint.robot
Resource   common/curl.robot
Resource   common/utils.robot

Variables   test/variables.yaml

