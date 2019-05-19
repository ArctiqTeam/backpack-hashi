# Consul ACL k8s Bootstrap

This project is designed as a helper Kubernetes pod intended to be run following the deployment of Consul in a k8s cluster via the official Hashicorp Helm Chart [here](https://github.com/hashicorp/consul-helm).

## Getting Started

A Consul cluster built via the official Consul Helm chart.

### Prerequisites

A Consul cluster built via the official Consul Helm chart.

```
Give examples
```

### Installing

A step by step series of examples that tell you how to get a development env running

Say what the step will be

```
Give the example
```
# kubectl create serviceaccount consul-acl-bootstrap -n consul

# kubectl apply -f - <<EOF
# kind: Role
# apiVersion: rbac.authorization.k8s.io/v1
# metadata:
#   name: consul-acl-bootstrap
#   namespace: consul
# rules:
# - apiGroups: [""]
#   resources:
#     - secrets
#   verbs: ["get", "create", "patch"]
# - apiGroups:
#   - apps
#   resources:
#     - statefulsets
#   verbs: ["get", "patch"]
# - apiGroups:
#   - extensions
#   resources:
#     - daemonsets
#   verbs: ["get", "patch"]
# EOF

# kubectl apply -f - <<EOF
# kind: RoleBinding
# apiVersion: rbac.authorization.k8s.io/v1
# metadata:
#   name: consul-acl-bootstrap
#   namespace: consul
# subjects:
# - kind: ServiceAccount
#   name: consul-acl-bootstrap 
#   namespace: consul 
# roleRef:
#   kind: Role
#   name: consul-acl-bootstrap
#   apiGroup: rbac.authorization.k8s.io
# EOF

# kubectl apply -f - <<EOF
# apiVersion: batch/v1
# kind: Job
# metadata:
#   name: consul-acl-bootstrap
#   namespace: consul
# spec:
#   backoffLimit: 1
#   activeDeadlineSeconds: 100
#   template:
#     spec:
#       serviceAccountName: consul-acl-bootstrap
#       containers:
#       - name: consul-acl-bootstrap
#         image: arctiqteam/consul-acl-bootstrap:1.9
#         args:
#           - "-n"
#           - "consul"
#           - "-s"
#           - "arctiqtim-consul"
#       restartPolicy: Never
# EOF

# Use the following in order to retrieve the tokens for operator use etc ...

# kubectl get secret acl-master-token -n $NAMESPACE -o json | jq -r '.data.token' | base64 -d
# kubectl get secret acl-agent-token -n $NAMESPACE -o json | jq -r '.data.token' | base64 -d


And repeat

```
until finished
```

End with an example of getting some data out of the system or using it for a little demo

## Running the tests

Explain how to run the automated tests for this system

### Break down into end to end tests

Explain what these tests test and why

```
Give an example
```

### And coding style tests

Explain what these tests test and why

```
Give an example
```

## Deployment

Add additional notes about how to deploy this on a live system

## Built With

* [Dropwizard](http://www.dropwizard.io/1.0.2/docs/) - The web framework used
* [Maven](https://maven.apache.org/) - Dependency Management
* [ROME](https://rometools.github.io/rome/) - Used to generate RSS Feeds

## Contributing

Please read [CONTRIBUTING.md](https://gist.github.com/PurpleBooth/b24679402957c63ec426) for details on our code of conduct, and the process for submitting pull requests to us.

## Versioning

We use [SemVer](http://semver.org/) for versioning. For the versions available, see the [tags on this repository](https://github.com/your/project/tags). 

## Authors

* **Billie Thompson** - *Initial work* - [PurpleBooth](https://github.com/PurpleBooth)

See also the list of [contributors](https://github.com/your/project/contributors) who participated in this project.

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details

## Acknowledgments

* Hat tip to anyone whose code was used
* Inspiration
* etc


gcloud builds submit --project arctiqteam-images --substitutions=TAG_NAME="1.9"