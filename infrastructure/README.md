# myapp Service

Spring Boot application 

* Modify settings.gradle with your project's name:

    ```groovy
    rootProject.name = 'myapp'
    ```

## running myapp locally
Run the following script locally to start up and run a simple curl test.
Note that there is a  wait to ensure the container is up
`./scripts/local_test.sh`

updates
1. myapp
2. myorg
3. myworkspace


terraform cloud needs:
1. organization
2. workspace per environment
3. aws creds configured per workspace

deployment pre-reqs:
1. VPC

TODO -
1. Add cloudwatch autoscaling policies
2. add bastion host

