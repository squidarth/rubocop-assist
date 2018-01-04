### Ruby Proctor

This is a web app to help write rubocop rules.

### Deployment with Kubernetes

This can be deployed via Kubernetes, and is dependent on [istio](istio.io) being deployed on your Kubernetes cluster.  See [this post](https://medium.com/@squidarth/running-user-provided-code-6c87b94720a3) for details on how to deploy this safely. The reason to do this is security--this app is complicated because it requires executing user-provided input.

* `$ kubectl apply -f istio-policy.yaml`
* `$ kubectl create -f <(istioctl kube-inject -f deployment.yaml)`
* `$ kubectl expose deployment rcrr1 --type=LoadBalancer --load-balancer-ip=$LOAD_BALANCER_IP  --port 80 --target-port 4567`

Instructions for installing istio are [here](https://istio.io/docs/setup/kubernetes/quick-start.html).

### Deployment as Ruby Process

This can be run as a simple sinatra app as well if you don't care about the security features:

* `$ bundle install`
* `$ ruby server.rb`
