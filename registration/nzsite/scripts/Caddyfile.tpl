{
    email ${admin_email}
%{ if test_cert }
    acme_ca https://acme-staging-v02.api.letsencrypt.org/directory
%{ endif }
}

${www_domain_name} {
    log stdout
%{ if stage != "prod" }
    basicauth / {
        preview JDJhJDEwJGdDcm9uR0EwOE9NQUFGNWx5Rzl5VHVjQmVaY1V2elJwbktDbi92YlU1S241anA1Z2lrWHM2
    }
%{ endif }
    reverse_proxy * web:3000 {
        header_up Host {host}
        header_up X-Real-IP {remote}
        header_up X-Forwarded-For {remote}
        header_up X-Forwarded-Port {server_port}
        header_up X-Forwarded-Proto {scheme}
    }
}

${sidekiq_domain_name} {
    log stdout

    reverse_proxy * worker:36465 {
        header_up Host {host}
        header_up X-Real-IP {remote}
        header_up X-Forwarded-For {remote}
        header_up X-Forwarded-Port {server_port}
        header_up X-Forwarded-Proto {scheme}
    }
}


