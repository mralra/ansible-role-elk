# ELK Ansible role

Installs the [ELK stack](https://www.elastic.co/products) (Elasticsearch, Logstash, and Kibana)
for log aggregation and monitoring. Intended for integration with [Riemann](http://riemann.io)
for alerting functionality.

## Requirements

* [freedomofpress.generate-ssl-cert] role
* 2GB of RAM for the logserver
* logclients to ship logs

## Role variables

```yaml
elk_nginx_user: "www-data"
elk_kibana_version: "4.4.1"

# Riemann plugin for alerting, de-dot filter for ElasticSearch v2 compatibility.
# See: https://www.elastic.co/blog/introducing-the-de_dot-filter
elk_logstash_plugins:
  - logstash-output-riemann
  - logstash-filter-de_dot

# Interface used for firewall restrictions and IPv4 lookups
elk_network_interface: eth0

elk_cluster_name: elk-logging

# SSL is disabled by default. Set these vars to the fullpaths to SSL
# certs you wish to use, and Nginx will force HTTPS connections.
# You must place the SSL certs there in a separate play.
elk_nginx_ssl_certificate: ""
elk_nginx_ssl_certificate_key: ""
elk_nginx_server_name: localhost

# Not safe for production use! Override to secure logins.
elk_kibana_username: kibana
elk_kibana_password: kibana

# Override to change the landing page, e.g. a custom dashboard:
# "dashboard/Your-Dashboard-Name". You must replace whitespace in
# dashboard names with hyphens, since Kibana expects it.
elk_kibana_default_app: discover

```

## Usage

Use the role in a playbook like this:

```yaml
- hosts: logserver
  roles:
    - role: elk
      elk_kibana_username: admin
      elk_kibana_password: WowWhatAStrongPassword4
```

## Adding visualizations

The role does not yet create Kibana visualizations automatically. You can however
import saved visualizations that ship with the role in `files/kibana-dashboards.json`.
Go to **Settings -> Objects -> Import** in the Kibana UI and browse to the JSON file.

## Running the tests

This role uses [Molecule] and [ServerSpec] for testing. To use it:

```
pip install molecule
gem install serverspec
molecule test
```

You can also run selective commands:

```
molecule idempotence
molecule verify
```

See the [Molecule] docs for more info.

## Further reading
### Setup

* [Official ElasticSearch docs](https://www.elastic.co/guide/index.html)
* [UCLA ELK configuration](https://www.itsecurity.ucla.edu/elk)
* [DigitalOcean guide to setting up ELK](https://www.digitalocean.com/community/tutorials/how-to-install-elasticsearch-logstash-and-kibana-elk-stack-on-ubuntu-14-04)

## License
MIT

[Molecule]: http://molecule.readthedocs.org/en/master/
[ServerSpec]: http://serverspec.org/
[freedomofpress.generate-ssl-cert]: https://github.com/freedomofpress/ansible-role-generate-ssl-cert
