# GitHub Actions Self Hosted Runner on Docker for Node.js Builds

Docker version of [self-hosted GitHub Actions runners](https://docs.github.com/en/actions/hosting-your-own-runners) to run Node.js builds. This installs all required dependencies to run Node.js builds. Also includes Docker and Docker Compose to run Docker commands in Docker, as well as Sonar scanner to run static analysis on builds.

## Environment Variables
| Variable | Description |
| ----------- | ----------- |
| RUNNER_VERSION | Version of the GitHub Runner [application](https://github.com/actions/runner/releases) that runs a job in a workflow. This is the version that will run on your container. |
| ACCESS_TOKEN | A personal access token to access GitHub. This is used to generate a token to register the runner when the container starts. This token must have  [privilges](https://docs.github.com/en/actions/hosting-your-own-runners/using-labels-with-self-hosted-runners) to add a runner within the repository or organization in which you wish to use the runner. |
| RUNNER_LABEL | The value that will be [used](https://docs.github.com/en/actions/hosting-your-own-runners/using-self-hosted-runners-in-a-workflow) by GitHub Actions to request the runner for a specific workflow. |
| RUNNER_WORK_DIRECTORY | Runner directory on the container. This contains the runner application files as well as files from any workflows that run on the container. |
| REPOSITORY_URL | If you only want the runner to have repository scope, rather than organization scope. |
