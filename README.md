# Swish Analytics DevSecOps Assessment

## General questions - Docker, CVEs, CI/CD, monitoring

1. Create an image with python2, python3, R, install a set of requirements and upload it to docker hub.
   - [ellipticalgadzooks/python_r_alpine](https://hub.docker.com/r/ellipticalgadzooks/python_r_alpine/tags)
2. For the previously created image 
   - Share build times
     - [Initial build](https://github.com/existere/swish-analytics-project/actions/runs/8099393750/job/22135027064) time of 12m 1s
   - How would you improve build times? 
     - After implementing a registry cache [the build](https://github.com/existere/swish-analytics-project/actions/runs/8099393750/job/22138074675) was reduced to 5s for the same image
     - Depending on the set of requirements, it might be faster to use a debian/ubuntu based image since most python packages include precompiled binary wheels on pypi, whereas alpine packages (if available) compile from source
     - Build a multi-stage dockerfile and compare the build times to the current dockerfile which uses the alpine native virtual packages, which are delted before final build
     - use a .dockerignore file
3. Scan the recently created container and evaluate the CVEs that it might contain. 
   - Create a report of your findings and follow best practices to remediate the CVE 
     - [report](https://github.com/existere/swish-analytics-project/actions/runs/8101930095/job/22143279617#step:7:24)
   - What would you do to avoid deploying malicious packages? 
     - In this case I could set the image scan step to fail on error before pushing to the registry and/or procution clusters
4. Use the created image to create a kubernetes deployment with a command that will keep the pod running
   - [deployment.yml](https://github.com/existere/swish-analytics-project/blob/main/deployment.yml)
5. Expose the deployed resource
   - [service.yml](https://github.com/existere/swish-analytics-project/blob/main/service.yml)
6. Every step mentioned above have to be in a code repository with automated CI/CD 
   - [GHA Workflow](https://github.com/existere/swish-analytics-project/blob/main/.github/workflows/docker-build.yaml)
7. How would you monitor the above deployment? Explain or implement the tools that you would use
   - Kubernetes dashboard deployed to the cluster. I would like to implement this solution if I have time before submitting the project. 
   - Other options: 
     - Prometheus and Grafana 
     - Cloudwatch
     - Datadog

## Project

The remainder of the project can be found in the following google doc:
[Swish Analytics DevSecOps Project](https://docs.google.com/document/d/1KGeBDE4-vv2OLh98tlRgXCKXT-JoRzlZQ6Ie4ZyhqLo/edit?usp=sharing)
