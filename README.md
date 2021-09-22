# ESCAPE AuthN/Z test suite 

TBD

## Running the testsuite with docker

This is the recommended way of running the testsuite. It requires you have a local oidc-agent configuration with a client named `escape-monitoring` registered on the [iam-escape](https://iam-escape.cloud.cnaf.infn.it/) instance.

To setup an environment for running the testsuite in docker,
use the following commands:

```bash
docker-compose up trust # and wait for fetch crl to be done
docker-compose up -d ts
```

Then run the entire testsuite with

```bash
docker-compose exec -T ts bash -c 'cd test-suite && OIDC_AGENT_SECRET=<secret> sh ci/run.sh'
```
where `<secret>` is the `escape-monitoring` client's secret.

### Datalake

The testsuite can also be runned against one of the registered endpoint.

Once the testsuite is UP, you can log into the container:

```bash
docker-compose exec ts bash
```

You will need to initialize oidc-agent inside the container. 

```bash
$ eval $(oidc-agent --no-autoload)
$ oidc-add escape-monitoring
```

You can then run the testsuite against one of the registered endpoint, _e.g._ `cnaf-amnesiac`

```bash
cd test-suite
./run-testsuite.sh cnaf-amnesiac
```

To add an endpoint, edit the `./test/variables.yaml` file.
